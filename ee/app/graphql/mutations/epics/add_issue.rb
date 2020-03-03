# frozen_string_literal: true

module Mutations
  module Epics
    class AddIssue < Base
      include Mutations::ResolvesIssuable

      graphql_name 'EpicAddIssue'

      authorize :update_epic

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the issue belongs to'

      argument :issue_iid, GraphQL::STRING_TYPE,
               required: true,
               description: 'The iid of the issue to be added'

      field :epic_issue,
            Types::EpicIssueLinkType,
            null: true,
            description: 'The epic-issue relation'

      def resolve(group_path:, iid:, project_path:, issue_iid:)
        epic = authorized_find!(group_path: group_path, iid: iid)
        issue = resolve_issuable(type: :issue, parent_path: project_path, iid: issue_iid)
        service = create_epic_issue(epic, issue)
        epic_issue = service[:status] == :success ? find_epic_issue(epic, issue) : nil

        {
          epic_issue: epic_issue,
          errors: service[:message] || []
        }
      end

      private

      def create_epic_issue(epic, issue)
        return unless epic.present? && issue.present?

        ::EpicIssues::CreateService.new(epic, current_user, { target_issuable: issue }).execute
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def find_epic_issue(epic, issue)
        EpicIssue.find_by!(epic: epic, issue: issue)
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
