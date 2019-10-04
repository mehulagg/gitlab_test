# frozen_string_literal: true
module EE
  module EnvironmentPolicy
    extend ActiveSupport::Concern

    prepended do
      condition(:can_access_to_protected_environment) { can_access_to_protected_environment? }

      rule { ~can_access_to_protected_environment }.policy do
        prevent :stop_environment
        prevent :create_environment_terminal
        prevent :create_environment
        prevent :update_environment
      end

      private

      alias_method :current_user, :user
      alias_method :environment, :subject

      def can_access_to_protected_environment?
        environment.protected_deployable_by_user?(current_user)
      end
    end
  end
end
