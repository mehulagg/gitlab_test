# frozen_string_literal: true

module Types
  class TodoStateEnum < BaseEnum
    value 'pending', deprecated: { reason: 'Use PENDING', milestone: '13.4' }
    value 'done', deprecated: { reason: 'Use DONE', milestone: '13.4' }
    value 'PENDING', value: 'pending'
    value 'DONE', value: 'done'
  end
end
