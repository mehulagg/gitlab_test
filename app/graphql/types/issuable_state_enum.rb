# frozen_string_literal: true

module Types
  class IssuableStateEnum < BaseEnum
    graphql_name 'IssuableState'
    description 'State of a GitLab issue or merge request'

    value 'OPENED', value: 'opened'
    value 'CLOSED', value: 'closed'
    value 'LOCKED', value: 'locked'
    value 'ALL', value: 'all'

    # Deprecated:
    value 'opened', deprecated: { reason: 'Use OPENED', milestone: '13.4' }
    value 'closed', deprecated: { reason: 'Use CLOSED', milestone: '13.4' }
    value 'locked', deprecated: { reason: 'Use LOCKED', milestone: '13.4' }
    value 'all', deprecated: { reason: 'Use ALL', milestone: '13.4' }
  end
end
