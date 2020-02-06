require 'securerandom'

# This component sets up the docker-test-saml-idp (https://github.com/kristophjunge/docker-test-saml-idp)
# image with the proper configuration for SAML integration.

module Gitlab
  module QA
    module Component
      class SAML
        include Scenario::Actable

        SAML_IMAGE = 'jamedjo/test-saml-idp'.freeze
        SAML_IMAGE_TAG = 'latest'.freeze

        attr_reader :docker
        attr_accessor :volumes, :network, :environment
        attr_writer :name

        def initialize
          @docker = Docker::Engine.new
          @environment = {}
          @volumes = {}
          @network_aliases = []
        end

        def set_entity_id(entity_id)
          @environment['SIMPLESAMLPHP_SP_ENTITY_ID'] = entity_id
        end

        def set_assertion_consumer_service(assertion_con_service)
          @environment['SIMPLESAMLPHP_SP_ASSERTION_CONSUMER_SERVICE'] = assertion_con_service
        end

        def add_network_alias(name)
          @network_aliases.push(name)
        end

        def name
          @name ||= "saml-qa-idp"
        end

        def hostname
          "#{name}.#{network}"
        end

        def group_name
          @group_name ||= "saml_sso_group-#{SecureRandom.hex(4)}"
        end

        def instance
          raise 'Please provide a block!' unless block_given?

          prepare
          start

          yield self
        ensure
          teardown
        end

        def prepare
          pull

          return if @docker.network_exists?(network)

          @docker.network_create(network)
        end

        # rubocop:disable Metrics/AbcSize
        def start
          docker.run(SAML_IMAGE, SAML_IMAGE_TAG) do |command|
            command << '-d '
            command << "--name #{name}"
            command << "--net #{network}"
            command << "--hostname #{hostname}"
            command << "--publish 8080:8080"
            command << "--publish 8443:8443"

            @volumes.to_h.each do |to, from|
              command.volume(to, from, 'Z')
            end

            @environment.to_h.each do |key, value|
              command.env(key, value)
            end

            @network_aliases.to_a.each do |network_alias|
              command << "--network-alias #{network_alias}"
            end
          end
        end
        # rubocop:enable Metrics/AbcSize

        def restart
          @docker.restart(name)
        end

        def teardown
          raise 'Invalid instance name!' unless name

          @docker.stop(name)
          @docker.remove(name)
        end

        def pull
          @docker.pull(SAML_IMAGE, SAML_IMAGE_TAG)
        end

        def set_sandbox_name(sandbox_name)
          ::Gitlab::QA::Runtime::Env.gitlab_sandbox_name = sandbox_name
        end

        def set_simple_saml_hostname
          ::Gitlab::QA::Runtime::Env.simple_saml_hostname = hostname
        end
      end
    end
  end
end
