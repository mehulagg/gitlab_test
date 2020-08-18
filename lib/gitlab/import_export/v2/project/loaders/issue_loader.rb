# frozen_string_literal: true
#
module Gitlab::ImportExport::V2::Project::Loaders
  class IssueLoader
    def self.load(data, project)
      data['issues'].each do |issue|
        project.issues.create!(issue)
      end
    end
  end
end
