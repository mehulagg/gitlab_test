# frozen_string_literal: true

module Mutations
  module Projects
    class Base < BaseMutation
      include Mutations::ResolvesProject

      argument :full_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project path'

      argument :description, GraphQL::STRING_TYPE,
               required: true,
               description: 'New desc'

      field :project,
            Types::ProjectType,
            null: false,
            description: 'The project after mutation'

      private

      def find_object(full_path:)
        resolve_project(full_path: full_path)
      end
    end
  end
end