# frozen_string_literal: true

module Mutations
  module Boards
    class UpdateEpicUserPreferences < ::Mutations::BaseMutation
      graphql_name 'UpdateBoardEpicUserPreferences'

      argument :board_id,
               ::Types::GlobalIDType[::Board],
               required: true,
               description: 'The board global id'

      argument :epic_id,
               ::Types::GlobalIDType[::Epic],
               required: true,
               description: 'The id of a board epic to set preferences for'

      argument :collapsed,
               GraphQL::BOOLEAN_TYPE,
               required: true,
               description: 'Whether the board epic should be collapsed'

      field :epic_user_preferences,
            Types::Boards::EpicUserPreferencesType,
            null: true,
            description: "The board epic user preferences after mutation."

      authorize :read_board

      def resolve(board_id:, epic_id:, **args)
        board = authorized_find!(id: board_id)

        result = ::Boards::EpicUserPreferences::UpdateService.new(
          current_user, board, epic_id.model_id, { collapsed: args[:collapsed] }).execute

        {
          epic_user_preferences: result[:epic_user_preferences],
          errors: result[:status] == :error ? [result[:message]] : []
        }
      end

      private

      def find_object(id:)
        GitlabSchema.object_from_id(id)
      end
    end
  end
end
