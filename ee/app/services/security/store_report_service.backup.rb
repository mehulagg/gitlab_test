# frozen_string_literal: true

module Security
  # Service for storing a given security report into the database.
  #
  class StoreReportService < ::BaseService
    include Gitlab::Utils::StrongMemoize

    attr_reader :pipeline, :report, :project

    def initialize(pipeline, report)
      @pipeline = pipeline
      @report = report
      @project = @pipeline.project
    end

    def launch
      pipeline = Ci::Pipeline.find 533
      project = pipeline.project
      report=pipeline.security_reports.reports['sast']
      Security::StoreReportService.new(pipeline, report).execute
    end

    def execute
      # Ensure we're not trying to insert data twice for this report
      return error("#{@report.type} report already stored for this pipeline, skipping...") if executed?

      with_diff = true

      if with_diff
        previous_report = get_previous_report

        report_diff = Security::CompareReportsService.new(project, previous_report, report).execute

        # flag the fixed
        report_diff.fixed.each do |occurrence|
          occurrence.flag_as_fixed!(@pipeline)
        end

        # Update the existing with their new location
        report_diff.existing.each do |occurrence|
          occurrence.update_location!(@pipeline)
          # Create occurrence_pipeline for this pipeline
          create_vulnerability_pipeline_object(occurrence, pipeline)
        end

        # Store only the new
        report_diff.added.each do |occurrence|
          create_vulnerability(occurrence)
        end
      else
        create_all_vulnerabilities!
      end

      success
    end

    # TODO: replace with first-class Report entity when available
    # rubocop: disable CodeReuse/ActiveRecord
    def get_previous_report
      previous_pipeline_with_report = project.vulnerabilities.where(report_type: report.type).order(id: :desc).first&.pipelines&.newest_first&.first

      previous_report = ::Gitlab::Ci::Reports::Security::Report.new(report.type, previous_pipeline_with_report&.sha)

      return previous_report unless previous_pipeline_with_report

      previous_pipeline_with_report.vulnerabilities.where(report_type: report.type).includes(:identifiers, :scanner).each do |occurrence|
        previous_report.add_occurrence(Gitlab::Ci::Reports::Security::Occurrence.from_database(occurrence))
      end

      previous_report
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def git_compare(start_sha, head_sha)
      git diff --patch --raw --abbrev=40 --full-index --find-renames=30% 20410773a37f49d599e5f0d45219b39304763538 a0a7bd6ba6ca5bb9a821dfb699f8e822185c4906 --master/codeclimate.json

      # start = from = target_sha
      # head = to = source
      start_sha = '20410773a37f49d599e5f0d45219b39304763538'
      # start_sha =  '1b35eea5b4cce17c098bcd6bbbac9ce13d598c68'
      head_sha = 'a0a7bd6ba6ca5bb9a821dfb699f8e822185c4906'
      project= Project.find 23

      compare = CompareService.new(project, head_sha).execute(project, start_sha, straight: false)
      diffs = compare.diffs(expanded: true)
      # diffs = compare.diffs(paths: ['master/codeclimate.json'], expanded: true)

      df = diffs.diff_files.first
      mapper = Gitlab::Diff::LineMapper.new(df)

      # diff_refs = Gitlab::Diff::DiffRefs.new(
      #   base_sha: nil,
      #   start_sha: 'a0a7bd6ba6ca5bb9a821dfb699f8e822185c4906',
      #   head_sha:  '1b35eea5b4cce17c098bcd6bbbac9ce13d598c68'
      # ).compare_in(project)
    end

    private

    def executed?
      pipeline.vulnerabilities.report_type(@report.type).any?
    end

    def create_all_vulnerabilities!
      @report.occurrences.each do |occurrence|
        create_vulnerability(occurrence)
      end
    end

    def create_vulnerability(occurrence)
      vulnerability = create_or_find_vulnerability_object(occurrence)

      occurrence[:identifiers].map do |identifier|
        create_vulnerability_identifier_object(vulnerability, identifier)
      end

      create_vulnerability_pipeline_object(vulnerability, pipeline)
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def create_or_find_vulnerability_object(occurrence)
      find_params = {
        scanner: scanners_objects[occurrence[:scanner]],
        primary_identifier: identifiers_objects[occurrence[:primary_identifier]],
        location_fingerprint: occurrence[:location_fingerprint]
      }

      create_params = occurrence.except(
        :scanner, :primary_identifier,
        :location_fingerprint, :identifiers)

      begin
        project.vulnerabilities
          .create_with(create_params)
          .find_or_create_by!(find_params)
      rescue ActiveRecord::RecordNotUnique
        project.vulnerabilities.find_by!(find_params)
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def create_vulnerability_identifier_object(vulnerability, identifier)
      vulnerability.occurrence_identifiers.find_or_create_by!( # rubocop: disable CodeReuse/ActiveRecord
        identifier: identifiers_objects[identifier])
    rescue ActiveRecord::RecordNotUnique
    end

    def create_vulnerability_pipeline_object(vulnerability, pipeline)
      vulnerability.occurrence_pipelines.find_or_create_by!(pipeline: pipeline) # rubocop: disable CodeReuse/ActiveRecord
    rescue ActiveRecord::RecordNotUnique
    end

    def scanners_objects
      strong_memoize(:scanners_objects) do
        @report.scanners.map do |key, scanner|
          [key, existing_scanner_objects[key] || project.vulnerability_scanners.build(scanner)]
        end.to_h
      end
    end

    def all_scanners_external_ids
      @report.scanners.values.map { |scanner| scanner[:external_id] }
    end

    def existing_scanner_objects
      strong_memoize(:existing_scanner_objects) do
        project.vulnerability_scanners.with_external_id(all_scanners_external_ids).map do |scanner|
          [scanner.external_id, scanner]
        end.to_h
      end
    end

    def identifiers_objects
      strong_memoize(:identifiers_objects) do
        @report.identifiers.map do |key, identifier|
          [key, existing_identifiers_objects[key] || project.vulnerability_identifiers.build(identifier)]
        end.to_h
      end
    end

    def all_identifiers_fingerprints
      @report.identifiers.values.map { |identifier| identifier[:fingerprint] }
    end

    def existing_identifiers_objects
      strong_memoize(:existing_identifiers_objects) do
        project.vulnerability_identifiers.with_fingerprint(all_identifiers_fingerprints).map do |identifier|
          [identifier.fingerprint, identifier]
        end.to_h
      end
    end
  end
end
