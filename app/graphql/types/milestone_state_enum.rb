# frozen_string_literal: true

module Types
  class MilestoneStateEnum < BaseEnum
    value 'ACTIVE', value: 'active'
    value 'CLOSED', value: 'closed'

    # Deprecated:
    value 'active', deprecated: { reason: 'Use ACTIVE', milestone: '13.4' }
    value 'closed', deprecated: { reason: 'Use CLOSED', milestone: '13.4' }
  end
end
