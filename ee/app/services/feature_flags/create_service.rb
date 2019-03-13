# frozen_string_literal: true

module FeatureFlags
  class CreateService < FeatureFlags::BaseService
    def execute
      ActiveRecord::Base.transaction do
        feature_flag = project.operations_feature_flags.new(params)

        if feature_flag.save
          create_default_scopes(feature_flag)

          save_audit_event(audit_event(feature_flag))

          success(feature_flag: feature_flag)
        else
          error(feature_flag.errors.full_messages)
        end
      end
    end

    private

    def audit_message(feature_flag)
      message_parts = ["Created feature flag <strong>#{feature_flag.name}</strong>",
                       "with description <strong>\"#{feature_flag.description}\"</strong>."]

      message_parts += feature_flag.scopes.map do |scope|
        created_scope_message(scope)
      end

      message_parts.join(" ")
    end

    def create_default_scopes(feature_flag)
      return unless permissions_enabled?

      environment_scopes = project.protected_environments.map(&:name)
      existing_scopes = feature_flag.scopes.map(&:environment_scope).to_set

      environment_scopes.each do |environment|
        next if existing_scopes.include?(environment)

        active = feature_flag.active_on_environment(environment)
        feature_flag.scopes.create!(environment_scope: environment, active: active)
      end
    end
  end
end
