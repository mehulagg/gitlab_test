# frozen_string_literal: true

module Mutations
  module Epics
    class AddIssue < Base
      graphql_name 'EpicAddIssue'

      authorize :admin_epic

      argument :group_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The group the epic is in'

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: "The project that the issue belongs to"

      argument :iid, GraphQL::STRING_TYPE,
               required: true,
               description: 'The iid of the epic'

      argument :issue_iid, GraphQL::STRING_TYPE,
               required: true,
               description: 'The iid of the issue to be added'

      field :epic,
            Types::EpicType,
            null: true,
            description: 'The epic after mutation'

      field :issue,
            Types::IssueType,
            null: true,
            description: 'The issue after mutation'

      field :epic_issue,
            Types::EpicIssueType,
            null: true,
            description: 'The epic issue relation'

      def resolve(args)
        group_path = args.delete(:group_path)
        epic_iid = args.delete(:iid)
        issue_iid = args.delete(:issue_iid)
        project_path = args.delete(:project_path)

        epic = authorized_find!(group_path: group_path, iid: epic_iid)
        issue = resolve_issue(current_user, project_path, issue_iid)
        create_params = { target_issuable: issue }

        service = ::EpicIssues::CreateService.new(epic, current_user, create_params).execute
        epic_issue = service[:status] == :success ? find_epic_issue(epic, issue) : nil

        {
          issue: issue.reset,
          epic: epic.reset,
          epic_issue: epic_issue,
          errors: service[:message] || []
        }
      end

      private

      def resolve_issue(current_user, project_path, issue_iid)
        project = resolve_project(current_user, project_path)

        Resolvers::IssuesResolver
          .single
          .new(object: project, context: { current_user: current_user })
          .resolve(iid: issue_iid)
      end

      def resolve_project(current_user, project_path)
        Resolvers::ProjectResolver
          .new(object: nil, context: { current_user: current_user })
          .resolve(full_path: project_path)
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def find_epic_issue(epic, issue)
        EpicIssue.find_by(epic: epic, issue: issue)
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
