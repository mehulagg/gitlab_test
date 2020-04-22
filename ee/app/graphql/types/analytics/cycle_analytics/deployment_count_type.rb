# frozen_string_literal: true

# rubocop: disable Graphql/AuthorizeTypes
module Types
  module Analytics
    module CycleAnalytics
      class DeploymentCountType < BaseObject
        graphql_name 'ValueStreamDeploymentCount'
        description 'Count of new deployments'

        field :title, GraphQL::STRING_TYPE, null: false,
          description: 'Title'
        field :value, GraphQL::INT_TYPE, null: false,
          description: 'Count'
      end
    end
  end
end
# rubocop: enable Graphql/AuthorizeTypes
