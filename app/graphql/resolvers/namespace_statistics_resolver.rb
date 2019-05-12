# frozen_string_literal: true

module Resolvers
  class NamespaceStatisticsResolver < BaseResolver
    argument :full_path, GraphQL::ID_TYPE,
             required: true,
             description: 'The full path of the group or namespace, e.g., "gitlab-org"'

    type Types::NamespaceStatisticsType, null: true

    def resolve(full_path:)
      Namespace.with_statistics.where_full_path_in([full_path]).take
    end
  end
end
