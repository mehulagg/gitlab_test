# frozen_string_literal: true
module ProtectedEnvironments
  class UpdateService < ::ProtectedEnvironments::BaseService
    def execute(protected_environment)
      protected_environment.assign_attributes(params)

      ActiveRecord::Base.transaction do
        next false unless protected_environment.save

        create_feature_flag_protected_scopes(protected_environment)

        true
      end
    end
  end
end
