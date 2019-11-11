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
          super()
          shell %Q{DOCKER_TLS_CERTDIR="" docker image rm #{@image}}
        end
      end
    end
  end
end
