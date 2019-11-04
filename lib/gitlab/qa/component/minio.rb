require 'securerandom'
require 'fileutils'

# This component sets up the Minio (https://hub.docker.com/r/minio/minio)
# image with the proper configuration for GitLab users to use object storage.
module Gitlab
  module QA
    module Component
      class Minio
        include Scenario::Actable

        MINIO_IMAGE = 'minio/minio'.freeze
        MINIO_IMAGE_TAG = 'latest'.freeze
        # These are secrets used in a local Minio container, they're not used for any online S3 server.
        AWS_ACCESS_KEY = 'AKIAIOSFODNN7EXAMPLE'.freeze
        AWS_SECRET_KEY = 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'.freeze
        DATA_DIR = '/data'.freeze
        DEFAULT_PORT = 9000

        attr_reader :docker
        attr_accessor :volumes, :network, :environment
        attr_writer :name

        def initialize
          @docker = Docker::Engine.new
          @environment = { MINIO_ACCESS_KEY: AWS_ACCESS_KEY, MINIO_SECRET_KEY: AWS_SECRET_KEY }
          @volumes = { host_data_dir => DATA_DIR }
          @buckets = []
        end

        def instance
          raise 'Please provide a block!' unless block_given?

          prepare
          start

          yield self
        ensure
          teardown
        end

        def add_bucket(name)
          @buckets << name
        end

        def to_config
          config = YAML.safe_load <<~CFG
            provider: AWS
            aws_access_key_id: #{AWS_ACCESS_KEY}
            aws_secret_access_key: #{AWS_SECRET_KEY}
            aws_signature_version: 4
            host: #{hostname}
            endpoint: http://#{hostname}:#{port}
            path_style: true
          CFG

          # Quotes get eaten up when the string is set in the environment
          config.to_s.gsub('"', '\\"')
        end

        private

        def host_data_dir
          base_dir = ENV['CI_PROJECT_DIR'] || '/tmp'

          File.join(base_dir, 'minio')
        end

        def name
          @name ||= "minio-#{SecureRandom.hex(4)}"
        end

        def hostname
          "#{name}.#{network}"
        end

        def port
          DEFAULT_PORT
        end

        def prepare
          @docker.pull(MINIO_IMAGE, MINIO_IMAGE_TAG)

          FileUtils.mkdir_p(host_data_dir)

          @buckets.each do |bucket|
            puts "Creating Minio bucket: #{bucket}"
            FileUtils.mkdir_p(File.join(host_data_dir, bucket))
          end

          return if @docker.network_exists?(network)

          @docker.network_create(network)
        end

        def start
          # --compat needed until https://gitlab.com/gitlab-org/gitlab-workhorse/issues/210
          # is resolved
          docker.run(MINIO_IMAGE, MINIO_IMAGE_TAG, "server", "--compat", DATA_DIR) do |command|
            command << '-d '
            command << "--name #{name}"
            command << "--net #{network}"
            command << "--hostname #{hostname}"

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

        def teardown
          raise 'Invalid instance name!' unless name

          @docker.stop(name)
          @docker.remove(name)
        end
      end
    end
  end
end
