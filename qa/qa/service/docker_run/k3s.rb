# frozen_string_literal: true

require 'securerandom'

module QA
  module Service
    module DockerRun
      class K3s < Base
        def initialize
          @image = 'registry.gitlab.com/gitlab-org/cluster-integration/test-utils/k3s-gitlab-ci/releases/v0.6.1'
          @name = "k3s-#{SecureRandom.hex(4)}"
          super
        end

        def register!
          pull
          start_k3s
        end

        def host_name
          return 'localhost' unless Runtime::Env.running_in_ci?

          super
        end

        def port
          @port ||= rand(6_000..6_999)
        end

        def kubeconfig
          read_file('/etc/rancher/k3s/k3s.yaml').chomp
        end

        def start_k3s
          command = <<~CMD.tr("\n", ' ')
            docker run -d --rm
            --network #{network}
            --hostname #{host_name}
            --name #{@name}
            --publish #{port}:6443
            --privileged
            #{@image} server
            --cluster-secret some-secret
            --no-deploy traefik
          CMD

          command.gsub!("--network #{network} --hostname #{host_name}", '') unless QA::Runtime::Env.running_in_ci?

          shell command
        end
      end
    end
  end
end
