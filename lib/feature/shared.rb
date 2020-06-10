# frozen_string_literal: true

# This file can contain only simple constructs as it is shared between:
# 1. `Pure Ruby`: `bin/feature-flag`
# 2. `GitLab Rails`: `lib/feature/definition.rb`

class Feature
  module Shared
    # optional: defines if a on-disk definition is required for this feature flag
    # rollout_issue: defines if `bin/feature-flag` asks for rollout issue
    # example: usage being shown when exception is raised
    TYPES = {
      development: {
        description: 'Short lived, used to enable unfinished code to be deployed',
        optional: true,
        rollout_issue: true,
        example: <<-EOS
          Feature.enabled?(:my_feature_flag)
          Feature.enabled?(:my_feature_flag, type: :development)
        EOS
      },
      ops: {
        description: 'Longer lived, used to disable features that have a performance impact, like special behavior of Sidekiq Jobs',
        optional: true,
        rollout_issue: false,
        example: <<-EOS
          Feature.enabled?(:my_feature_flag, type: ops)
        EOS
      }
    }.freeze

    PARAMS = %i[
      name
      default_enabled
      type
      introduced_by_url
      rollout_issue_url
      group
    ].freeze
  end
end
