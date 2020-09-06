# frozen_string_literal: true

module Types
  class HealthStatusEnum < BaseEnum
    graphql_name 'HealthStatus'
    description 'Health status of an issue or epic'

    value 'ON_TRACK', value: Issue.health_statuses.key(1)
    value 'NEEDS_ATTENTION', value: Issue.health_statuses.key(2)
    value 'AT_RISK', value: Issue.health_statuses.key(3)

    # Deprecated:
    value 'onTrack', value: Issue.health_statuses.key(1), deprecated: { reason: 'Use ON_TRACK', milestone: '13.4' }
    value 'needsAttention', value: Issue.health_statuses.key(2), deprecated: { reason: 'Use NEEDS_ATTENTION', milestone: '13.4' }
    value 'atRisk', value: Issue.health_statuses.key(3), deprecated: { reason: 'Use AT_RISK', milestone: '13.4' }
  end
end
