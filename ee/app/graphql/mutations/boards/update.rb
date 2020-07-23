# frozen_string_literal: true

module Mutations
  module Boards
    class Update < Base
      graphql_name 'UpdateBoard'

      authorize :read_board

      argument :id,
                GraphQL::ID_TYPE,
                required: true,
                description: 'The global id of the note to update'

      argument :name,
               GraphQL::STRING_TYPE,
               required: false,
               description: copy_field_description(::Types::BoardType, :name)

      argument :weight,
               GraphQL::INTEGER,
               required: false,
               description: copy_field_description(::Types::BoardType, :weight)

      argument :hide_labels,
               GraphQL::BOOLEAN_TYPE,
               required: false,
               description: copy_field_description(Types::BoardUserPreference, :hide_labels)

      field :board,
            ::Types::BoardType,
            null: true,
            description: "The board after mutation"

      def resolve(id:)
        # issue = authorized_find!(project_path: project_path, iid: iid)
        # project = issue.project

        # ::Issues::UpdateService.new(project, current_user, iteration: iteration)
        #   .execute(issue)

        # {
        #   issue: issue,
        #   errors: issue.errors.full_messages
        # }
      end

      private

      def find_object(id:)
        GitlabSchema.object_from_id(id)
      end
    end
  end
end
