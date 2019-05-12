# frozen_string_literal: true

module Types
  class NamespaceStatisticsType < NamespaceType
    graphql_name 'NamespaceStatistics'

    authorize :read_statistics

    field :storage_size, GraphQL::INT_TYPE, null: false
    field :repository_size, GraphQL::INT_TYPE, null: false
    field :lfs_objects_size, GraphQL::INT_TYPE, null: false
    field :build_artifacts_size, GraphQL::INT_TYPE, null: false
    field :packages_size, GraphQL::INT_TYPE, null: false
  end
end
