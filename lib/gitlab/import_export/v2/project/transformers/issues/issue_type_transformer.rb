# frozen_string_literal: true

module Gitlab::ImportExport::V2::Project::Transformers::Issues
  class IssueTypeTransformer
    def self.transform(data)
      data['issues'].map do |issue|
        next unless issue['type']

        type = Issue.issue_types[issue.delete('type').downcase]

        issue['issue_type'] = type || 0
        issue
      end

      data
    end
  end
end
