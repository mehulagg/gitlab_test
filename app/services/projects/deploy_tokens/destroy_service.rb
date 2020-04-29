# frozen_string_literal: true

module Projects
  module DeployTokens
    class DestroyService < ::ContainerBaseService
      include DeployTokenMethods

      def execute
        destroy_deploy_token(@project, params)
      end
    end
  end
end
