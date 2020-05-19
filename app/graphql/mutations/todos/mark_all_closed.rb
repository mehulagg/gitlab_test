# frozen_string_literal: true

module Mutations
  module Todos
    class MarkAllClosed < ::Mutations::Todos::Base
      graphql_name 'TodosMarkAllClosed'

      authorize :update_user

      field :updated_ids,
            [GraphQL::ID_TYPE],
            null: false,
            description: 'Ids of the updated todos'

      def resolve
        authorize!(current_user)

        updated_ids = mark_all_todos_closed

        {
          updated_ids: map_to_global_ids(updated_ids),
          errors: []
        }
      end

      private

      def mark_all_todos_closed
        return [] unless current_user

        TodoService.new.mark_all_todos_as_closed_by_user(current_user)
      end
    end
  end
end
