# frozen_string_literal: true

module Types
  class IterationStateEnum < BaseEnum
    graphql_name 'IterationState'
    description 'State of a GitLab iteration'

    value 'UPCOMING', value: 'upcoming'
    value 'STARTED', value: 'started'
    value 'OPENED', value: 'opened'
    value 'CLOSED', value: 'closed'
    value 'ALL', value: 'all'

    # Deprecated:
    value 'upcoming', deprecated: { reason: 'Use UPCOMING', milestone: '13.4' }
    value 'started', deprecated: { reason: 'Use STARTED', milestone: '13.4' }
    value 'opened', deprecated: { reason: 'Use OPENED', milestone: '13.4' }
    value 'closed', deprecated: { reason: 'Use CLOSED', milestone: '13.4' }
    value 'all', deprecated: { reason: 'Use ALL', milestone: '13.4' }
  end
end
