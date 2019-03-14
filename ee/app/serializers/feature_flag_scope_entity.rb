# frozen_string_literal: true

class FeatureFlagScopeEntity < Grape::Entity
  include RequestAwareEntity

  expose :id
  expose :active
  expose :environment_scope
  expose :created_at
  expose :updated_at

  expose :can_update do |feature_flag_scope|
    project = feature_flag_scope.feature_flag.project
    project.protected_environment_accessible_to?(feature_flag_scope.environment_scope, current_user)
  end

  expose :protected do |feature_flag_scope|
    project = feature_flag_scope.feature_flag.project
    project.protected_environment_by_name(feature_flag_scope.environment_scope).present?
  end

  private

  def current_user
    request.current_user
  end
end
