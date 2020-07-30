# frozen_string_literal: true

module MergeCommits
  class ExportCsvService
    TARGET_FILESIZE = 15000000

    def initialize(current_user, group_id)
      @current_user = current_user
      @group_id = group_id
    end

    def csv_data
      csv_builder.render(TARGET_FILESIZE)
    end

    private

    attr_reader :current_user, :group_id

    def csv_builder
      @csv_builder ||= CsvBuilder.new(data, header_to_value_hash)
    end

    def data
      MergeRequestsFinder.new(current_user, finder_options).execute.merged
    end

    def finder_options
      {
        group_id: group_id
      }
    end

    def header_to_value_hash
      {
        'Merge commit sha' => 'merge_commit_sha',
        'Author' => -> (merge_request) { merge_request.author&.name },
        'Merge Request' => 'id',
        'Merged By' => -> (merge_request) { merge_request.metrics&.merged_by&.name },
        'Pipeline' => -> (merge_request) { merge_request.metrics&.pipeline_id },
        'Group' => -> (merge_request) { merge_request.source_project_namespace },
        'Project' => -> (merge_request) { merge_request.project&.name },
        'Approver(s)' => -> (merge_request) { merge_request.approved_by_users.map(&:name).join(" | ") }
      }
    end
  end
end
