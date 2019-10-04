# frozen_string_literal: true

class EnvironmentPolicy < BasePolicy
  delegate { @subject.project }

  condition(:stop_with_deployment_allowed) do
    @subject.stop_action_available? &&
      can?(:create_deployment) && can?(:update_build, @subject.stop_action)
  end

  condition(:stop_with_update_allowed) do
    !@subject.stop_action_available? && can?(:update_environment, @subject)
  end

  rule { stop_with_deployment_allowed | stop_with_update_allowed }.enable :stop_environment

  condition(:creator) do
    @subject.last_deployment.created_by?(@user) # TODO: We do not presist user to environments table today
  end

  rule { can?(:create_environment) & creator }.policy do
    enable :update_environment
  end
end

EnvironmentPolicy.prepend_if_ee('EE::EnvironmentPolicy')
