# frozen_string_literal: true

module Gitlab::ImportExport::V2::Project::Transformers::Issues
  class IssueDiscussionsTransformer
    def self.transform(data, project)
      data['issues'].map do |issue|
        next unless issue['discussions']

        issue['notes'] ||= []

        issue['discussions'].map do |discussion|
          discussion_id = discussion['id'].split('/').last

          discussion.delete('id')

          discussion['notes'].map do |note|
            note['discussion_id'] = discussion_id
            note['note'] = note['body']
            note['project_id'] = project.id
            note['noteable_type'] = 'Issue'

            note.delete('body')
            note.delete('noteable_id')

            issue['notes'] << Note.new(note)
          end
        end

        issue.delete('discussions')

        issue
      end

      data
    end
  end
end
