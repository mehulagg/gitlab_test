# frozen_string_literal: true

module QA
  module Service
    module DockerRun
      class DependencyProxy < Base
        def initialize(group)
          uri = URI.parse(Runtime::Scenario.gitlab_address)
          @image = "#{uri.host}:#{uri.port}/#{group.full_path.tr(' ', '')}/dependency_proxy/containers/alpine:latest"
          @name = "qa-proxy-#{SecureRandom.hex(8)}"

          super()
        end

        def pull
          setup_insecure_registry
          super()
          shell %Q{docker image rm #{@image}}
          clean_insecure_registry
        end

        private

        def setup_insecure_registry
          shell %Q{echo '{ "insecure-registries" : ["#{uri.host}:#{uri.port}"] }' > /etc/docker/daemon.json}
          shell %q{service docker restart}
        end

        def clean_insecure_registry
          shell %q{rm /etc/docker/daemon.json}
          shell %q{service docker restart}
        end
      end
    end
  end
end
