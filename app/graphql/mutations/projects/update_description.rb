# frozen_string_literal: true

# mutation {
#   projectsUpdateDecription(input: {fullPath: "root/tanuki", description: "hehehe"}) {
#     project {
#       description
#     } errors
#   }
# }

module Mutations
  module Projects
    class UpdateDescription < Base
      graphql_name 'ProjectsUpdateDecription'

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