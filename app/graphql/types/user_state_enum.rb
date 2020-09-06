# frozen_string_literal: true

module Types
  class UserStateEnum < BaseEnum
    graphql_name 'UserState'
    description 'Possible states of a user'

    value 'ACTIVE', value: 'active', description: 'The user is active and is able to use the system'
    value 'BLOCKED', value: 'blocked', description: 'The user has been blocked and is prevented from using the system'
    value 'DEACTIVATED', value: 'deactivated', description: 'The user is no longer active and is unable to use the system'

    # Deprecated:
    value 'active', 'The user is active and is able to use the system', deprecated: { reason: 'Use ACTIVE', milestone: '13.4' }
    value 'blocked', 'The user has been blocked and is prevented from using the system', deprecated: { reason: 'Use BLOCKED', milestone: '13.4' }
    value 'deactivated', 'The user is no longer active and is unable to use the system', deprecated: { reason: 'Use DEACTIVATED', milestone: '13.4' }
  end
end
