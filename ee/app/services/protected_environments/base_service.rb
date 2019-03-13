# frozen_string_literal: true
module ProtectedEnvironments
  class BaseService < ::BaseService
    protected

    def create_feature_flag_protected_scopes(protected_environment)
      return unless Feature.enabled?(:feature_flag_permissions, project)

      project.operations_feature_flags.each do |feature_flag|
        next if feature_flag.scopes.find { |scope| scope.environment_scope == protected_environment.name }

        active = feature_flag.active_on_environment(protected_environment.name)
        feature_flag.scopes.create!(environment_scope: protected_environment.name, active: active)
      end
    end
  end
end
