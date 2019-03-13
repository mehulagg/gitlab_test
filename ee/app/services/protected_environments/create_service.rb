# frozen_string_literal: true
module ProtectedEnvironments
  class CreateService < ::ProtectedEnvironments::BaseService
    def execute
      protected_environment = project.protected_environments.new(params)

      ActiveRecord::Base.transaction do
        if protected_environment.save
          create_feature_flag_protected_scopes(protected_environment)
        end
      end

      protected_environment
    end
  end
end
