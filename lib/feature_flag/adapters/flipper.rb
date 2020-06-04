# frozen_string_literal: true

require 'flipper/adapters/active_record'
require 'flipper/adapters/active_support_cache_store'

module FeatureFlag
  module Adapters
    class Flipper
      # Classes to override flipper table names
      class FlipperFeature < ::Flipper::Adapters::ActiveRecord::Feature
        # Using `self.table_name` won't work. ActiveRecord bug?
        superclass.table_name = 'features'

        def self.feature_names
          pluck(:key)
        end
      end

      class FlipperGate < ::Flipper::Adapters::ActiveRecord::Gate
        superclass.table_name = 'feature_gates'
      end

      class << self
        delegate :group, to: :flipper

        def available?
          true
        end
      
        def all
          flipper.features.to_a
        end
    
        def get(key)
          flipper.feature(key)
        end

        def persisted_names
          return [] unless Gitlab::Database.exists?
    
          if Gitlab::Utils.to_boolean(ENV['FF_LEGACY_PERSISTED_NAMES'])
            # To be removed:
            # This uses a legacy persisted names that are know to work (always)
            Gitlab::SafeRequestStore[:flipper_persisted_names] ||=
              begin
                # We saw on GitLab.com, this database request was called 2300
                # times/s. Let's cache it for a minute to avoid that load.
                Gitlab::ProcessMemoryCache.cache_backend.fetch('flipper:persisted_names', expires_in: 1.minute) do
                  FlipperFeature.feature_names
                end.to_set
              end
          else
            # This loads names of all stored feature flags
            # and returns a stable Set in the following order:
            # - Memoized: using Gitlab::SafeRequestStore or @flipper
            # - L1: using Process cache
            # - L2: using Redis cache
            # - DB: using a single SQL query
            flipper.adapter.features
          end
        end
    
        def persisted_name?(feature_name)
          # Flipper creates on-memory features when asked for a not-yet-created one.
          # If we want to check if a feature has been actually set, we look for it
          # on the persisted features list.
          persisted_names.include?(feature_name.to_s)
        end

        # This method is called from config/initializers/flipper.rb and can be used
        # to register Flipper groups.
        # See https://docs.gitlab.com/ee/development/feature_flags.html#feature-groups
        def register_feature_groups
        end

        def persisted?(feature)
          # Flipper creates on-memory features when asked for a not-yet-created one.
          # If we want to check if a feature has been actually set, we look for it
          # on the persisted features list.
          persisted_names.include?(feature.name.to_s)
        end

        def table_exists?
          FlipperFeature.table_exists?
        end

        private

        def flipper
          if Gitlab::SafeRequestStore.active?
            Gitlab::SafeRequestStore[:flipper] ||= build_flipper_instance
          else
            @flipper ||= build_flipper_instance
          end
        end

        def persisted_names
          Gitlab::SafeRequestStore[:flipper_persisted_names] ||=
            begin
              # We saw on GitLab.com, this database request was called 2300
              # times/s. Let's cache it for a minute to avoid that load.
              Gitlab::ThreadMemoryCache.cache_backend.fetch('flipper:persisted_names', expires_in: 1.minute) do
                FlipperFeature.feature_names
              end
            end
        end

        def build_flipper_instance
          active_record_adapter = Flipper::Adapters::ActiveRecord.new(
            feature_class: FlipperFeature,
            gate_class: FlipperGate)
    
          # Redis L2 cache
          redis_cache_adapter =
            Flipper::Adapters::ActiveSupportCacheStore.new(
              active_record_adapter,
              l2_cache_backend,
              expires_in: 1.hour)
    
          # Thread-local L1 cache: use a short timeout since we don't have a
          # way to expire this cache all at once
          flipper_adapter = Flipper::Adapters::ActiveSupportCacheStore.new(
            redis_cache_adapter,
            l1_cache_backend,
            expires_in: 1.minute)
    
          Flipper.new(flipper_adapter).tap do |flip|
            flip.memoize = true
          end
        end

        def l1_cache_backend
          Gitlab::ProcessMemoryCache.cache_backend
        end
    
        def l2_cache_backend
          Rails.cache
        end
      end
    end
  end
end
