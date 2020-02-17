require 'securerandom'

module Gitlab
  module QA
    module Component
      ##
      # This class represents GitLab QA specs image that is implemented in
      # the `qa/` directory located in GitLab CE / EE repositories.
      #
      class Specs < Scenario::Template
        attr_accessor :suite, :release, :network, :args, :volumes, :env

        def initialize
          @docker = Docker::Engine.new
          @volumes = {}
          @env = {}
        end

        def perform # rubocop:disable Metrics/AbcSize
          raise ArgumentError unless [suite, release].all?

          if release.dev_gitlab_org?
            Docker::Command.execute(
              [
                'login',
                '--username gitlab-qa-bot',
                %(--password "#{Runtime::Env.dev_access_token_variable}"),
                Release::DEV_REGISTRY
              ]
            )
          end

          puts "Running test suite `#{suite}` for #{release.project_name}"

          name = "#{release.project_name}-qa-#{SecureRandom.hex(4)}"

          @docker.run(release.qa_image, release.qa_tag, suite, *args) do |command|
            command << "-t --rm --net=#{network || 'bridge'}"

            env.merge(Runtime::Env.variables).each do |key, value|
              command.env(key, value)
            end

            command.volume('/var/run/docker.sock', '/var/run/docker.sock')
            command.volume(File.join(Runtime::Env.host_artifacts_dir, name), File.join(Docker::Volumes::QA_CONTAINER_WORKDIR, 'tmp'))

            @volumes.to_h.each do |to, from|
              command.volume(to, from)
            end

            command.name(name)
          end
        end
      end
    end
  end
end
