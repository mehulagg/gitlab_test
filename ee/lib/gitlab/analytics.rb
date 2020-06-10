# frozen_string_literal: true

module Gitlab
  module Analytics
    # Normally each analytics feature should be guarded with a feature flag.
    CYCLE_ANALYTICS_FEATURE_FLAG = :cycle_analytics
    PRODUCTIVITY_ANALYTICS_FEATURE_FLAG = :productivity_analytics

    FEATURE_FLAGS = [
      CYCLE_ANALYTICS_FEATURE_FLAG,
      PRODUCTIVITY_ANALYTICS_FEATURE_FLAG
    ].freeze

    FEATURE_FLAG_DEFAULTS = {
      PRODUCTIVITY_ANALYTICS_FEATURE_FLAG => true,
      CYCLE_ANALYTICS_FEATURE_FLAG => true
    }.freeze

    FEATURE_FLAGS_TYPE = {
      # TODO: it seems that we use a licensed "feature"
      PRODUCTIVITY_ANALYTICS_FEATURE_FLAG => :licensed,
      CYCLE_ANALYTICS_FEATURE_FLAG => :development
    }.freeze

    def self.any_features_enabled?
      FEATURE_FLAGS.any? do |flag|
        feature_enabled?(flag)
      end
    end

    def self.cycle_analytics_enabled?
      feature_enabled?(CYCLE_ANALYTICS_FEATURE_FLAG)
    end

    def self.productivity_analytics_enabled?
      feature_enabled?(PRODUCTIVITY_ANALYTICS_FEATURE_FLAG)
    end

    def self.feature_enabled_by_default?(flag)
      !!FEATURE_FLAG_DEFAULTS[flag]
    end

    def self.feature_enabled?(feature)
      Feature.enabled?(feature,
        type: FEATURE_FLAGS_TYPE.fetch(feature),
        default_enabled: feature_enabled_by_default?(feature))
    end
  end
end
