# frozen_string_literal: true

# rubocop: disable Graphql/AuthorizeTypes
module Types
  module Analytics
    module CycleAnalytics
      class NewIssueCountType < BaseObject
        graphql_name 'ValueStreamNewIssueCount'
        description 'Count of opened issues'

        field :title, GraphQL::STRING_TYPE, null: false,
          description: 'Title'
        field :value, GraphQL::INT_TYPE, null: false,
          description: 'Count of opened issues'
      end
    end
  end
end
# rubocop: enable Graphql/AuthorizeTypes
