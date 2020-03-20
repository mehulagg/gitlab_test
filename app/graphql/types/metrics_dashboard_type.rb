# frozen_string_literal: true

module Types
  class MetricsDashboardType < BaseObject
    graphql_name 'MetricsDashboard'
    description 'Describes metrics dashboard for the environment where project is deployed to'


    field :name, GraphQL::STRING_TYPE, null: false,
          description: 'Human-readable name of the environment'

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'ID of the environment'

    field :annotations,
          Types::MetricsDashboardAnnotationType.connection_type,
          null: true,
          description: 'A single metrics dashboard of environment',
          resolver: Resolvers::MetricsDashboardAnnotationsResolver

  end
end
