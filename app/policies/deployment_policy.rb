# frozen_string_literal: true

class DeploymentPolicy < BasePolicy
  delegate { @subject.project }

  condition(:internal) do
    @subject.internal?
  end

  condition(:can_retry_deployable) do
    can?(:update_build, @subject.deployable)
  end

  rule { internal & ~can_retry_deployable }.policy do
    prevent :create_deployment
    prevent :update_deployment
  end

  condition(:creator) do
    @subject.created_by?(@user)
  end

  rule { can?(:create_deployment) & creator }.policy do
    enable :update_deployment
  end
end

EnvironmentPolicy.prepend_if_ee('EE::DeploymentPolicy')
