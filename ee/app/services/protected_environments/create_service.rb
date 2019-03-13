# frozen_string_literal: true
module ProtectedEnvironments
  class CreateService < BaseService
    def execute
      protected_environment = project.protected_environments.new(params)
      if protected_environment.save
        create_feature_flag_protected_scopes(protected_environment)
      end

      protected_environment
    end

    private

    def create_feature_flag_protected_scopes(protected_environment)
      project.operations_feature_flags.each do |feature_flag|
        next if feature_flag.scopes.find { |scope| scope.environment_scope == protected_environment.name }

        feature_flag.scopes.create!(environment_scope: protected_environment.name, active: false)
      end
    end
  end
end
