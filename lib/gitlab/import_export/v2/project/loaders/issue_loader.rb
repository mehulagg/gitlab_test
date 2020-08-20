# frozen_string_literal: true
#
module Gitlab::ImportExport::V2::Project::Loaders
  class IssueLoader
    def self.load(data, project)
      data['issues'].each do |i|
        notes = i.delete('notes')
        issue = project.issues.create!(i)
        issue.notes.create!(notes)
      end
    end
  end
end
