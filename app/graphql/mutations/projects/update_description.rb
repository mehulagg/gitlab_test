# frozen_string_literal: true

module Mutations
  module Projects
    class UpdateDescription < Base
      graphql_name 'ProjectsUpdateDescription'

      argument :description, GraphQL::STRING_TYPE,
               required: true,
               description: "New description"

      authorize :read_project

      def resolve(full_path:, description:)
        project = authorized_find!(full_path: full_path)

        project.update(description: description)

        {
          project: project,
          errors: project.errors.full_messages
        }
      end
    end
  end
end