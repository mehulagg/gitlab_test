# frozen_string_literal: true

module Types
  class EpicStateEnum < BaseEnum
    graphql_name 'EpicState'
    description 'State of an epic.'

    value 'ALL', value: 'all'
    value 'OPENED', value: 'opened'
    value 'CLOSED', value: 'closed'

    # Deprecated:
    value 'all', deprecated: { reason: 'Use ALL', milestone: '13.4' }
    value 'opened', deprecated: { reason: 'Use OPENED', milestone: '13.4' }
    value 'closed', deprecated: { reason: 'Use CLOSED', milestone: '13.4' }
  end
end
