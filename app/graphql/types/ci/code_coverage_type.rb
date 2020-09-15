# frozen_string_literal: true

module Types
  module Ci
    class CodeCoverageType < BaseObject
      graphql_name 'CodeCoverage'
      description 'Represents the daily code coverage for a project'

      authorize :read_build_report_results

      field :average, GraphQL::FLOAT_TYPE, null: true,
            description: 'Percentage of coverage for the project'

      field :count, GraphQL::INT_TYPE, null: true,
            description: 'Number of coverage for the project'

      field :last_update_at, Types::TimeType, null: true,
            description: 'Latest date of coverage for the project'
    end
  end
end
