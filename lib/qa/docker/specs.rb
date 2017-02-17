require 'rspec/core'

module QA
  module Docker
    class Specs
      include Scenario::Actable
      ##
      # This should be changed to `gitlab/gitlab-qa` after we start
      # pushing QA images to Docker Hub
      #
      IMAGE_NAME = 'registry.gitlab.com/gitlab-org/gitlab-qa-specs'

      def initialize
        @docker = Docker::Engine.new
      end

      def test(gitlab)
        tag = "#{gitlab.release}-#{gitlab.tag}"
        args = ['Test::Instance', gitlab.address, gitlab.release]

        @docker.run(IMAGE_NAME, tag, *args) do |command|
          command << "-t --rm --net #{gitlab.network}"
          command << "--name #{gitlab.name}-specs"
        end
      end
    end
  end
end
