# frozen_string_literal: true

module Types
  class MergeRequestStateEnum < IssuableStateEnum
    graphql_name 'MergeRequestState'
    description 'State of a GitLab merge request'

    value 'MERGED', value: 'merged'

    # Deprecated:
    value 'merged', deprecated: { reason: 'Use MERGED', milestone: '13.4' }
  end
end
