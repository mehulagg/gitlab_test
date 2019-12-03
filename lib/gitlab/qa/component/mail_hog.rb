# This component sets up the MailHog (https://github.com/mailhog/MailHog)
# image with the proper configuration for SMTP email delivery from Gitlab

module Gitlab
  module QA
    module Component
      class MailHog
        include Scenario::Actable

        MAILHOG_IMAGE = 'mailhog/mailhog'.freeze
        MAILHOG_IMAGE_TAG = 'v1.0.0'.freeze

        attr_reader :docker
        attr_accessor :environment, :network
        attr_writer :name

        def initialize
          @docker = Docker::Engine.new
          @environment = {}
        end

        def name
          @name ||= "mailhog"
        end

        def hostname
          "#{name}.#{network}"
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
          @docker.pull(MAILHOG_IMAGE, MAILHOG_IMAGE_TAG)

          return if @docker.network_exists?(network)

          @docker.network_create(network)
        end

        def start
          docker.run(MAILHOG_IMAGE, MAILHOG_IMAGE_TAG) do |command|
            command << '-d '
            command << "--name #{name}"
            command << "--net #{network}"
            command << "--hostname #{hostname}"
            command << "--publish 1025:1025"
            command << "--publish 8025:8025"
          end
        end

        def restart
          @docker.restart(name)
        end

        def teardown
          raise 'Invalid instance name!' unless name

          @docker.stop(name)
          @docker.remove(name)
        end

        def set_mailhog_hostname
          ::Gitlab::QA::Runtime::Env.mailhog_hostname = hostname
        end
      end
    end
  end
end
