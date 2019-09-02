# frozen_string_literal: true

module FeatureFlag
  module Adapters
    class Unleash
      class Feature
        attr_reader :key

        def initialize(key)
          @key = key.to_s
        end

        def enabled?(thing = nil)
          client.is_enabled?(key, context(thing))
        end

        def off?(thing = nil)
          !enabled?(thing)
        end

        def enable(thing = true)
          # Not Supported yet (See https://gitlab.com/gitlab-org/gitlab-ee/issues/9566)
        end
    
        def disable(thing = false)
          # Not Supported yet (See https://gitlab.com/gitlab-org/gitlab-ee/issues/9566)
        end
    
        def enable_group(group)
          # Not Supported yet (See https://gitlab.com/gitlab-org/gitlab-ee/issues/9566)
        end
    
        def disable_group(group)
          # Not Supported yet (See https://gitlab.com/gitlab-org/gitlab-ee/issues/9566)
        end

        def remove
          # Not Supported yet (See https://gitlab.com/gitlab-org/gitlab-ee/issues/9566)
        end

        private

        def client
          FeatureFlag::Adapters::Unleash.client
        end

        def context(thing)
          ::Unleash::Context.new(properties: { thing: thing })
        end
      end

      class << self
        def available?
          Gitlab.config.unleash.enabled
        end

        def all
          Unleash::ToggleFetcher.toggle_cache
        end

        def get(key)
          Feature.new(key)
        end

        def persisted?(feature)
          true # TODO: Fix
        end

        def table_exists?
          true
        end

        def configure
          ::Unleash.configure do |config|
            config.url            = Gitlab.config.unleash.url
            config.app_name       = Gitlab.config.unleash.app_name
            config.instance_id    = Gitlab.config.unleash.instance_id
            config.logger         = Gitlab::Unleash::Logger
          end
        end

        def client
          # TODO: Fix
          @client ||= if defined?(UNLEASH)
                        UNLEASH
                      elsif defined?(Rails.configuration.unleash)
                        Rails.configuration.unleash
                      else
                        ::Unleash::Client.new(
                          url: Gitlab.config.unleash.url,
                          app_name: Gitlab.config.unleash.app_name,
                          instance_id: Gitlab.config.unleash.instance_id,
                          logger: Gitlab::Unleash::Logger)
                      end
        end
      end
    end
  end
end
