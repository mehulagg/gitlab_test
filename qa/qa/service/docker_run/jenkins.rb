# frozen_string_literal: true

module QA
  module Service
    module DockerRun
      class Jenkins < Base
        include QA::Runtime::IPAddress

        def initialize
          @image = 'registry.gitlab.com/gitlab-org/gitlab-qa/jenkins-gitlab:version1'
          @name = 'jenkins-server'
          @port = '8080'
          super()
        end

        def host_address
          "http://#{host_name}:#{@port}"
        end

        def host_name
          if Scenario.gitlab_address.include?('localhost')
            'localhost'
          elsif QA::Runtime::Env.running_in_ci? && !URI.parse(Scenario.gitlab_address).host.include?('test') # Running in CI against static env
            fetch_current_ip_address
          else
            super
          end
        end

        def register!
          command = <<~CMD.tr("\n", ' ')
            docker run -d --rm
            --network #{network}
            --hostname #{host_name}
            --name #{@name}
            --env JENKINS_HOME=jenkins_home
            --publish #{@port}:8080
            --publish 50000:50000
            #{@image}
          CMD

          command.gsub!("--network #{network} ", '') unless QA::Runtime::Env.running_in_ci?

          shell command
        end
      end
    end
  end
end
