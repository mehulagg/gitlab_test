# frozen_string_literal: true

module Types
  module Ci
    class DailyBuildGroupReportResultType < BaseObject
      graphql_name 'DailyBuildGroupReportResult'
      description 'Represents a DailyBuildGroupReportResult'

      authorize :read_build_report_results

      field :id, GraphQL::ID_TYPE, null: false,
            description: 'ID of the DailyBuildGroupReportResult'
      field :group_name, GraphQL::STRING_TYPE, null: false,
            description: 'Group name of the DailyBuildGroupReportResult'
      field :date, GraphQL::STRING_TYPE, null: false,
            description: 'Date of the DailyBuildGroupReportResult'
      # field :data,  GraphQL::STRING_TYPE, null: false,
            # description: 'Id of the project'
    end
  end
end
