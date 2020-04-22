# frozen_string_literal: true

# rubocop: disable Graphql/AuthorizeTypes
module Types
  module Analytics
    module CycleAnalytics
      class SummaryType < BaseObject
        graphql_name 'ValueStreamSummary'
        description 'Represents the summary of value stream analytics for a given time range'

        field :new_issue_count, NewIssueCountType, null: false,
          description: 'Count of new issues'
        field :deployment_count, DeploymentCountType, null: false,
          description: 'Count of new deployments'
        field :deployment_frequency, DeploymentFrequencyType, null: false,
          description: 'Deployment count per day'
      end
    end
  end
end
# rubocop: enable Graphql/AuthorizeTypes
