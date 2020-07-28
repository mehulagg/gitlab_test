# frozen_string_literal: true

# This file can contain only simple constructs as it is shared between:
# 1. `Pure Ruby`: `bin/feature-flag`
# 2. `GitLab Rails`: `lib/feature/definition.rb`

class Feature
  module Shared
    # optional: defines if a on-disk definition is required for this feature flag type
    # rollout_issue: defines if `bin/feature-flag` asks for rollout issue
    # example: usage being shown when exception is raised
    TYPES = {
      development: {
        description: 'Short lived, used to enable unfinished code to be deployed',
        optional: true,
        rollout_issue: true,
        default_actor: nil,
        example: <<-EOS
          Feature.enabled?(:my_feature_flag)
          Feature.enabled?(:my_feature_flag, type: :development)
        EOS
      },
      ops: {
        description: 'Longer lived, used to disable features that have a performance impact, like special behavior of Sidekiq Jobs',
        optional: true,
        rollout_issue: false,
        default_actor: "Instance",
        example: <<-EOS
          Feature.enabled?(:my_feature_flag, type: ops)
        EOS
      },
      licensed: {
        description: 'Forever, used like a config to enable rollout licensed features for certain users',
        optional: true,
        rollout_issue: false,
        # The usage is undefined, we use licensed feature flags in many contexes
        default_actor: %w[User Namespace Project].freeze,
        example: <<-EOS
          project.feature_available?(:my_licensed_feature)
          project.beta_feature_available?(:my_licensed_feature)
          project.alpha_feature_available?(:my_licensed_feature)

          namespace.feature_available?(:my_licensed_feature)
          namespace.beta_feature_available?(:my_licensed_feature)
          namespace.alpha_feature_available?(:my_licensed_feature)

          push_frontend_feature_flag(:my_licensed_feature, type: :licensed)
        EOS
      }
    }.freeze

    PARAMS = %i[
      name
      default_enabled
      type
      actor
      introduced_by_url
      rollout_issue_url
      group
    ].freeze

    ACTORS = %w[Instance Project Namespace User].freeze
  end
end
