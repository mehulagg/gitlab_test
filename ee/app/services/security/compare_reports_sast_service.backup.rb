# frozen_string_literal: true

module Security
  class CompareReportsSastService < CompareReportsBaseService
    # Loop on base report occurrences, try to update their location
    # by leveraging the Git diff, and find a match in head report by
    # comparing primary identifier and location fingerprints
    def find_existing_and_fixed_occurrences
      git_diff = get_git_diff

      # FIXME: handle all possible outputs for get_git_diff
      raise "no git diff" unless git_diff

      FIXME: deal with vulns without file_path or start_line


      # Group by file path to optimize the usage of Diff::File and Diff::LineMapper
      base_report.occurrences.group_by(&:file_path).each do |file_path, occurrences|
        diff_file = git_diff.diff_file_with_old_path(file_path)

        check_with_diff_file(diff_file, occurrences)
      end
    end

    def check_with_diff_file(diff_file, occurrences)
      if diff_file.nil?
        # This file is not part of the diff, but we still compare
        # the occurrences with the new reported ones!!!
        occurrences.each do |occurrence|
          exist_in_head_report?(occurrence)
        end

        return
      end

      if diff_file.deleted_file?
        # Flag all occurrences as fixed
        occurrences.each do |occurrence|
          report_diff.fixed << occurrence
        end

        return
      end

      mapper = Gitlab::Diff::LineMapper.new(diff_file)

      check_with_mapper(mapper, occurrences)
    end

    def check_with_mapper(mapper, occurrences)
      occurrences.each do |occurrence|
        new_path = mapper.diff_file.new_path
        new_start_line = mapper.old_to_new(occurrence.start_line)
        unless occurrence.end_line.blank?
          new_end_line = mapper.old_to_new(occurrence.end_line)
        end

        if new_start_line.nil?
          # If the line was removed, there is no mapped line number.
          # Flag occurrence as fixed
          report_diff.fixed << occurrence

          next
        end

        new_location = Gitlab::Ci::Reports::Security::Locations::Sast.new(
          file_path: new_path,
          start_line: new_start_line,
          end_line: new_end_line
        )
        clone = Gitlab::Ci::Reports::Security::Occurrence.clone(occurrence)

        exist_in_head_report?(occurrence, new_location)
      end
    end


    def exist_in_head_report?(occurrence, new_location = nil)
      # FIXME: find a DRY way to generate the location_fingerprint
      head_occurrence = @head_report.find_occurrence(occurrence.primary_identifier&.fingerprint, new_location&.fingerprint || occurrence.location_fingerprint)
      head_occurrence = @head_report.occurrences.find { |o| o == occurrence )

      # If the occurrence is not present in the head report we flag it as fixed
      if head_occurrence.nil?
        @report_diff.fixed << occurrence

        return
      end

      # Otherwise flag it as existing
      @report_diff.existing << occurrence

      # Also keep the head occurrence attached to the occurrence for later use
      # occurrence.updated_occurrence = head_occurrence
    end

    def generate_location_fingerprint(location)
      Digest::SHA1.hexdigest("#{location[:file]}:#{location[:start_line]}:#{location[:end_line]}")
    end

    def get_git_diff
      # Compare commits
      compare = CompareService.new(project, head_report.commit_sha).execute(project, base_report.commit_sha, straight: false)
      # FIXME: Compare service can return nil, we nust handle this
      return unless compare

      # TODO: we can probably improve the process by only updating
      # the occurrences whose file_path is part of the diff
      # modified_paths = compare.modified_paths
      # occurrences_to_update = previous_occurrences.select do |occurrence|
      #   modified_paths.includes?(occurrence.file_path)
      # end

      # TODO: We could get the Git diff only for relevant files but by doing so we loose the
      # information about renamed files. We know the file has been deleted but no idea
      # about what is the new name :/ Maybe look for another approach here.
      # relevant_paths = occurrences_to_update.map(&:file_path).uniq
      # git_diff = compare.diffs(paths: relevant_paths, expanded: true)

      # Get the git diff
      compare.diffs(expanded: true)
    end
  end
end
