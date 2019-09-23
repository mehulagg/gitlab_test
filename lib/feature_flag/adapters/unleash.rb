# frozen_string_literal: true

module FeatureFlag
  module Adapters
    class Unleash
      class Feature
        attr_accessor :active
        attr_accessor :strategies
        attr_reader :name

        alias_attribute :state, :active

        Gate = Struct.new(:key, :value)

        def initialize(name)
          @name = name.to_s
        end

        def enabled?(thing = nil)
          client.is_enabled?(name, context(thing))
        end

        def off?(thing = nil)
          !enabled?(thing)
        end

        def enable(thing = true)
          HTTParty.post(Unleash.enable_feature_flag_url(name),
            headers: Unleash.request_headers,
            body: { name: name,
                    environment_scope: Gitlab.config.unleash.app_name,
                    strategy: strategy_for(thing).to_json })
        end

        def disable(thing = false)
          HTTParty.post(Unleash.disable_feature_flag_url(name),
            headers: Unleash.request_headers,
            body: { name: name,
                    environment_scope: Gitlab.config.unleash.app_name,
                    strategy: strategy_for(thing).to_json })
        end
    
        def enable_group(group)
          # Not Supported yet (See https://gitlab.com/gitlab-org/gitlab-ee/issues/9566)
        end
    
        def disable_group(group)
          # Not Supported yet (See https://gitlab.com/gitlab-org/gitlab-ee/issues/9566)
        end

        def remove
          HTTParty.post(Unleash.delete_feature_flag_url(name),
            headers: Unleash.request_headers,
            body: { name: name,
                    environment_scope: Gitlab.config.unleash.app_name })
        end

        def persisted?
          toggles = ::Unleash.toggles
          toggles.present? && toggles.any? { |toggle| toggle['name'] == name }
        end

        def gates
          @gates ||= strategies.map { |strategy| Gate.new(strategy['name'], strategy['parameters']) }
        end

        def gate_values
          @gate_values ||= strategies.inject({}) do |hash, strategy|
            hash[strategy['name']] = strategy['parameters'].to_s
            hash
          end
        end

        private

        def strategy_for(thing)
          if thing.in?([true, false])
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
          response = HTTParty.get(get_feature_flag_scopes_url,
            headers: request_headers,
            query: { environment_scope: Gitlab.config.unleash.app_name }
          )

          response.map do |scope|
            feature = Feature.new(scope['name'])
            feature.active = scope['active']
            feature.strategies = scope['strategies']
            feature
          end
        end

        def get(key)
          Feature.new(key)
        end

        def persisted?(feature)
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

        def get_feature_flag_scopes_url
          "#{api_endpoint}/feature_flag_scopes"
        end

        def enable_feature_flag_url(key)
          "#{api_endpoint}/feature_flags/#{key}/enable"
        end

        def disable_feature_flag_url(key)
          "#{api_endpoint}/feature_flags/#{key}/disable"
        end

        def delete_feature_flag_url(key)
          "#{api_endpoint}/feature_flags/#{key}"
        end

        def api_endpoint
          strong_memoize(:api_endpoint) do
            api_url, project_id = Gitlab.config.unleash.url
              .scan( %r{(https?://.*/api/v4)/feature_flags/unleash/(\d+)} )
              .first

            "#{api_url}/projects/#{project_id}/"
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
                          logger: Gitlab::Unleash::Logger,
                          disable_metrics: true)
                      end
        end
      end
    end
  end
end
