# frozen_string_literal: true

module Types
  module Ci
    class CodeCoverageType < BaseObject
      graphql_name 'CodeCoverage'
      description 'Represents a the daily code coverage for a project'

      field :coverage, GraphQL::INT_TYPE, null: false,
            description: 'Percent of coverage for the project'

      field :coverage_count, GraphQL::INT_TYPE, null: false,
            description: 'Number of coverage for the project'

      field :last_update, GraphQL::STRING_TYPE, null: false,
            description: 'Latest date of coverage for the project'
    end
  end
end
