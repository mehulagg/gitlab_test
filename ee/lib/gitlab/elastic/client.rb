# frozen_string_literal: true

require 'faraday_middleware/aws_sigv4'

module Gitlab
  module Elastic
    module Client
      CLIENT_MUTEX = Mutex.new

      cattr_accessor :cached_clients, default: {}
      cattr_accessor :cached_configs, default: {}

      # Returns a cached client instance for the given index.
      #
      # All models will use the same instance per index, which is refreshed
      # automatically if the settings change.
      def self.cached(index)
        CLIENT_MUTEX.synchronize do
          config = index.connection_config

          if cached_clients[index.id].nil? || config != cached_configs[index.id]
            cached_clients[index.id] = build(config)
            cached_configs[index.id] = config
          end
        end

        cached_clients[index.id]
      end

      # Takes a hash as returned by `ElasticsearchIndex#connection_config`,
      # and configures itself based on those parameters
      def self.build(config)
        base_config = {
          urls: config[:urls],
          randomize_hosts: true,
          retry_on_failure: true
        }

        if config[:aws]
          creds = resolve_aws_credentials(config)
          region = config[:aws_region]

          ::Elasticsearch::Client.new(base_config) do |fmid|
            fmid.request(:aws_sigv4, credentials: creds, service: 'es', region: region)
          end
        else
          ::Elasticsearch::Client.new(base_config)
        end
      end

      def self.resolve_aws_credentials(config)
        # Resolve credentials in order
        # 1.  Static config
        # 2.  ec2 instance profile
        static_credentials = Aws::Credentials.new(config[:aws_access_key], config[:aws_secret_access_key])

        return static_credentials if static_credentials&.set?

        # Instantiating this will perform an API call, so only do so if the
        # static credentials did not work
        instance_credentials = Aws::InstanceProfileCredentials.new

        instance_credentials if instance_credentials&.set?
      end
    end
  end
end
