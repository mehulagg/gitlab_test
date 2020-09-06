# frozen_string_literal: true

module Types
  class TodoActionEnum < BaseEnum
    value 'ASSIGNED', value: 1
    value 'MENTIONED', value: 2
    value 'BUILD_FAILED', value: 3
    value 'MARKED', value: 4
    value 'APPROVAL_REQUIRED', value: 5
    value 'UNMERGEABLE', value: 6
    value 'DIRECTLY_ADDRESSED', value: 7

    # Deprecated:
    value 'assigned', value: 1, deprecated: { reason: 'Use ASSIGNED', milestone: '13.4' }
    value 'mentioned', value: 2, deprecated: { reason: 'Use MENTIONED', milestone: '13.4' }
    value 'build_failed', value: 3, deprecated: { reason: 'Use BUILD_FAILED', milestone: '13.4' }
    value 'marked', value: 4, deprecated: { reason: 'Use MARKED', milestone: '13.4' }
    value 'approval_required', value: 5, deprecated: { reason: 'Use APPROVAL_REQUIRED', milestone: '13.4' }
    value 'unmergeable', value: 6, deprecated: { reason: 'Use UNMERGEABLE', milestone: '13.4' }
    value 'directly_addressed', value: 7, deprecated: { reason: 'Use DIRECTLY_ADDRESSED', milestone: '13.4' }
  end
end
