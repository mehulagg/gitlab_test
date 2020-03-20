# frozen_string_literal: true

module Types
  class MetricsDashboardAnnotationType < BaseObject
    graphql_name 'MetricsDashboardAnnotation'
    description 'Describes metrics dashboard for the environment where project is deployed to'


    field :description, GraphQL::STRING_TYPE, null: false,
          description: 'Human-readable description of the annotation'

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'ID of the environment'

    field :panel_id, GraphQL::STRING_TYPE, null: true,
          description: 'ID of a dashboard panel to which the annotation should be scoped'

    field :from, GraphQL::STRING_TYPE, null: false,
          description: 'The annotaiton starting timestamp'''

    field :to, GraphQL::STRING_TYPE, null: true,
          description: 'The annotaiton ending timestamp'
  end
end
