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

    argument :search_namespaces, GraphQL::BOOLEAN_TYPE,
             required: false,
             description: 'Include namespace in project search'

    def resolve(**args)
      ProjectsFinder
        .new(current_user: current_user, params: project_finder_params(args))
        .execute
    end

    private

    def project_finder_params(params)
      {
        without_deleted: true,
        non_public: params[:membership],
        search: params[:search],
        search_namespaces: params[:search_namespaces]
      }.compact
    end
  end
end
