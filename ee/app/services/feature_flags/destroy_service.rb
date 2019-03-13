# frozen_string_literal: true

module FeatureFlags
  class DestroyService < FeatureFlags::BaseService
    def execute(feature_flag)
      permission_error = check_permissions(feature_flag)
      return error(permission_error) if permission_error

      ActiveRecord::Base.transaction do
        if feature_flag.destroy
          save_audit_event(audit_event(feature_flag))

          success(feature_flag: feature_flag)
        else
          error(feature_flag.errors.full_messages)
        end
      end
    end

    private

    def audit_message(feature_flag)
      "Deleted feature flag <strong>#{feature_flag.name}</strong>."
    end

    def check_permissions(feature_flag)
      return unless permissions_enabled?

      feature_flag.scopes.each do |scope|
        unless environment_accessible_to_user?(scope.environment_scope)
          return permission_error_message(scope.environment_scope)
        end
      end

      nil
    end
  end
end
