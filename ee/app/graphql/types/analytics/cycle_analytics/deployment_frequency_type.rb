# frozen_string_literal: true

# rubocop: disable Graphql/AuthorizeTypes
module Types
  module Analytics
    module CycleAnalytics
      class DeploymentFrequencyType < BaseObject
        graphql_name 'ValueStreamDeploymentFrequency'
        description 'Deployment frequency per day'

        field :title, GraphQL::STRING_TYPE, null: false,
          description: 'Title'
        field :value, GraphQL::INT_TYPE, null: false,
          description: 'Number of deployments per day'
      end
    end
  end
end
# rubocop: enable Graphql/AuthorizeTypes
