# frozen_string_literal: true

module Resolvers
  class ProjectsResolver < BaseResolver
    type Types::ProjectType, null: true

    argument :membership, GraphQL::BOOLEAN_TYPE,
             required: false,
             description: 'Limit projects that the current user is a member of'

    argument :search, GraphQL::STRING_TYPE,
             required: false,
             description: 'Search query for project name, path, or description'

    argument :ids, [GraphQL::ID_TYPE],
            required: false,
            description: 'Filter projects by IDs'

    def resolve(**args)
      ProjectsFinder
        .new(current_user: current_user, params: project_finder_params(args), project_ids_relation: parse_gids(args[:ids]))
        .execute
    end

    private

    def project_finder_params(params)
      {
        without_deleted: true,
        non_public: params[:membership],
        search: params[:search]
      }.compact
    end

    def parse_gids(gids)
      gids&.map { |gid| GitlabSchema.parse_gid(gid, expected_type: ::Project).model_id }
    end
  end
end
