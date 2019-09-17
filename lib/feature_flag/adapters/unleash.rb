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
          puts "#{self.class.name} - #{__callee__}: 1"
          response = HTTParty.post(Unleash.enable_feature_flag_url,
            headers: Unleash.request_headers,
            body: { name: @key,
                    environment_scope: Gitlab.config.unleash.app_name,
                    strategy: strategy_for(thing).to_json })

          puts "#{self.class.name} - #{__callee__}: 2"
          Sidekiq.logger.debug("#{self.class.name} - #{__callee__}: response: #{response}")

          puts "#{self.class.name} - #{__callee__}: 3"
          response
        end

        def disable(thing = false)
          response = HTTParty.post(Unleash.disable_feature_flag_url,
            headers: Unleash.request_headers,
            body: { name: @key,
                    environment_scope: Gitlab.config.unleash.app_name,
                    strategy: strategy_for(thing).to_json })

          Sidekiq.logger.debug("#{self.class.name} - #{__callee__}: response: #{response}")

          response
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

        def persisted?
          toggles = ::Unleash.toggles
          toggles.present? && toggles.select { |toggle| toggle['name'] == @key }
        end

        private

        def strategy_for(thing)
          if thing == true
            { name: 'default', parameters: {} }
          else
            { name: 'userWithId', parameters: { userIds: sanitized(thing) } }
          end
        end

        def client
          FeatureFlag::Adapters::Unleash.client
        end

        def context(thing)
          ::Unleash::Context.new(properties: { thing: sanitized(thing) })
        end

        def sanitized(thing)
          thing = thing.__getobj__ if thing.respond_to?(:__getobj__) # Resolve SimpleDelegator

          return thing unless thing.is_a?(ActiveRecord::Base)

          "#{thing.class.name}:#{thing.id}"
        end
      end

      class << self
        include Gitlab::Utils::StrongMemoize

        def available?
          Gitlab.config.unleash.enabled
        end

        def all
          # TODO: Wrap in Feature
          Unleash.toggles
        end

        def get(key)
          Feature.new(key)
        end

        def persisted?(feature)
          # get(key).persisted?
          feature.persisted?
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

        def enable_feature_flag_url
          "#{api_endpoint}/enable"
        end

        def disable_feature_flag_url
          "#{api_endpoint}/disable"
        end

        def api_endpoint
          strong_memoize(:api_endpoint) do
            api_url, project_id = Gitlab.config.unleash.url
              .scan( %r{(https?://.*/api/v4/)feature_flags/unleash/(\d+)} )
              .first

            "#{api_url}/projects/#{project_id}/feature_flags"
          end
        end

        def request_headers
          strong_memoize(:request_headers) do
            { 'Private-Token': Gitlab.config.unleash.personal_access_token }
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
