# frozen_string_literal: true

require 'set'

class Feature
  class Gitaly
    # Server feature flags should use '_' to separate words.
    SERVER_FEATURE_FLAGS =
      %w[
        cache_invalidator
        inforef_uploadpack_cache
        commit_without_batch_check
        use_core_delta_islands
      ].freeze

    DEFAULT_ON_FLAGS = Set.new([]).freeze

    class << self
      def enabled?(feature_flag)
        return false unless Feature::FlipperFeature.table_exists?

        default_on = DEFAULT_ON_FLAGS.include?(feature_flag)
        Feature.enabled?("gitaly_#{feature_flag}", default_enabled: default_on)
      rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad
        false
      end

      def server_feature_flags
        SERVER_FEATURE_FLAGS.map do |f|
          ["gitaly-feature-#{f.tr('_', '-')}", enabled?(f).to_s]
        end.to_h
      end
    end
  end
end
