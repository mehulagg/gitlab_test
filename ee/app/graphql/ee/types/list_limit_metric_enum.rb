# frozen_string_literal: true

module EE
  module Types
    class ListLimitMetricEnum < ::Types::BaseEnum
      graphql_name 'ListLimitMetric'
      description 'List limit metric setting'

      value 'ALL_METRICS', value: 'all_metrics'
      value 'ISSUE_COUNT', value: 'issue_count'
      value 'ISSUE_WEIGHTS', value: 'issue_weights'

      # Deprecated
      value 'all_metrics', deprecated: { reason: 'Use ALL_METRICS', milestone: '13.4' }
      value 'issue_count', deprecated: { reason: 'Use ISSUE_COUNT', milestone: '13.4' }
      value 'issue_weights', deprecated: { reason: 'Use ISSUE_WEIGHTS', milestone: '13.4' }
    end
  end
end
