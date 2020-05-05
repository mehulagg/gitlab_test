module Gitlab
  module QA
    module Component
      class PostgreSQL
        include Scenario::Actable

        POSTGRES_IMAGE = 'postgres'.freeze
        POSTGRES_IMAGE_TAG = '11'.freeze

        attr_reader :docker
        attr_accessor :environment, :network
        attr_writer :name

        def initialize
          @docker = Docker::Engine.new
          @environment = {}
        end

        def name
          @name ||= "postgres"
        end

        def instance
          prepare
          start
          wait_until_ready
          yield self
        ensure
          teardown
        end

        def prepare
          @docker.pull(POSTGRES_IMAGE, POSTGRES_IMAGE_TAG)
          return if @docker.network_exists?(network)

          @docker.network_create(network)
        end

        def start
          @docker.run(POSTGRES_IMAGE, POSTGRES_IMAGE_TAG) do |command|
            command << "-d"
            command << "--name #{name}"
            command << "--net #{network}"

            command.env("POSTGRES_PASSWORD", "SQL_PASSWORD")
          end
        end

        def teardown
          @docker.stop(name)
          @docker.remove(name)
        end

        def run_psql(command)
          @docker.exec(name, %(psql -U postgres #{command}))
        end

        private

        def wait_until_ready
          start = Time.now
          begin
            run_psql 'template1'
          rescue StandardError
            retry if Time.now - start < 30
            raise
          end
        end
      end
    end
  end
end
