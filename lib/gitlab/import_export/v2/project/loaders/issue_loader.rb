# frozen_string_literal: true
#
module Gitlab::ImportExport::V2::Project::Loaders
  class IssueLoader
    def self.load(data, project)
      data['issues'].each do |i|
        issue = Issue.new(i)
        issue.assign_attributes(project_id: project.id)
        issue.importing = true if issue.respond_to?(:importing?)
        issue.save!
      end
    end
  end
end
