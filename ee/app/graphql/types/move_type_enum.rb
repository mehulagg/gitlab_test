# frozen_string_literal: true

module Types
  class MoveTypeEnum < BaseEnum
    graphql_name 'MoveType'
    description 'The position to which the adjacent object should be moved'

    value 'BEFORE', value: 'before', description: 'The adjacent object will be moved before the object that is being moved'
    value 'AFTER', value: 'after', description: 'The adjacent object will be moved after the object that is being moved'

    # Deprecated:
    value 'before', 'The adjacent object will be moved before the object that is being moved', deprecated: { reason: 'Use BEFORE', milestone: '13.4' }
    value 'after', 'The adjacent object will be moved after the object that is being moved', deprecated: { reason: 'Use AFTER', milestone: '13.4' }
  end
end
