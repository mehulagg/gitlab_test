# frozen_string_literal: true
module EE
  module DeploymentPolicy
    extend ActiveSupport::Concern

    prepended do
      condition(:can_access_to_protected_environment) { can_access_to_protected_environment? }

      rule { ~can_access_to_protected_environment }.policy do
        prevent :create_deployment
        prevent :update_deployment
      end

      private

      alias_method :current_user, :user
      alias_method :deployment, :subject

      def can_access_to_protected_environment?
        deployment.environment.protected_deployable_by_user?(current_user)
      end
    end
  end
end
