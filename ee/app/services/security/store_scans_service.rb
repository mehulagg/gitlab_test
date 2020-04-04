# frozen_string_literal: true

module Security
  class StoreScansService
    def initialize(build)
      @build = build
    end

    def execute
      return if @build.canceled? || @build.skipped?

      security_reports = @build.job_artifacts.security_reports

      json_parser = Gitlab::Ci::Parsers::Security::Report.new

      scan_params = security_reports.map do |job_artifact|
        {
          build: @build,
          scan_type: job_artifact.file_type,
          scanned_resources_count: json_parser.scanned_resources_count(job_artifact),
          raw_metadata: raw_metadata(job_artifact)
        }
      end

      ActiveRecord::Base.transaction do
        scan_params.each do |param|
          scan = Security::Scan.safe_find_or_create_by!(param.except(:raw_metadata))
          scan.update_attribute(:raw_metadata, param[:raw_metadata])
        end
      end
    end

    def raw_metadata(job_artifact)
      return {} if job_artifact.file_type != 'dast'

      trace_parser = Gitlab::Ci::Parsers::Security::DastTrace.new
      {
        scanned_resources: {
          trace_line_number: trace_parser.line_number(@build.trace)
        }
      }
    end
  end
end
