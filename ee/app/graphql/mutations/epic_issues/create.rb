# frozen_string_literal: true

module Mutations
  module EpicIssues
    class Create < Base
      graphql_name 'CreateEpicIssue'

      argument :epic_iid, GraphQL::STRING_TYPE,
               required: true,
               description: "The iid of the epic"

      field :id, type: GraphQL::ID_TYPE, null: false,
            description: 'ID (global ID) of the epic issue relation'

      field :epic, ::Types::EpicType, null: true,
            description: 'Epic to which this issue was assigned to'

      def resolve(project_path:, iid:, epic_iid:)
        issue = authorized_find!(project_path: project_path, iid: iid)
        epic = resolve_epic(current_user, issue, epic_iid)
        create_params = { target_issuable: issue }

        unless epic.present?
          raise Gitlab::Graphql::Errors::ResourceNotAvailable,
            'The epic that you are attempting to access does not exist '\
            'or you don\'t have permission to perform this action'
        end

        service = ::EpicIssues::CreateService.new(epic, current_user, create_params).execute

        {
          id: (find_epic_issue_id(epic, issue) if service[:status] == :success),
          issue: issue,
          epic: epic,
          errors: service[:message] || []
        }
      end

      private

      def resolve_epic(current_user, issue, epic_iid)
        return unless epic_iid.present?

        group = issue.project.group
        return unless group.present?

        Resolvers::EpicResolver
          .single
          .new(object: group, context: { current_user: current_user })
          .resolve(iid: epic_iid)
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def find_epic_issue_id(epic, issue)
        EpicIssue.find_by(epic: epic, issue: issue).try(:id)
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
