# frozen_string_literal: true

module FeatureFlags
  class BaseService < ::BaseService
    AUDITABLE_ATTRIBUTES = %w(name description).freeze

    protected

    def audit_event(feature_flag)
      message = audit_message(feature_flag)

      return if message.blank?

      details =
        {
          custom_message: message,
          target_id: feature_flag.id,
          target_type: feature_flag.class.name,
          target_details: feature_flag.name
        }

      ::AuditEventService.new(
        current_user,
        feature_flag.project,
        details
      )
    end

    def save_audit_event(audit_event)
      return unless audit_event

      audit_event.security_event
    end

    def created_scope_message(scope)
      strategy_text = created_strategy_text(scope.strategies)
      "Created rule <strong>#{scope.environment_scope}</strong> #{strategy_text}"\
      "and set it as <strong>#{scope.active ? "active" : "inactive"}</strong>."
    end

    def created_strategy_text(strategies)
      strategy = strategies.first
      template = "with <strong>%s%%</strong> rollout "
      if strategy && strategy['parameters'] && !strategy['parameters']['percentage'].blank?
        sprintf(template, strategy['parameters']['percentage'])
      else
        ""
      end
    end
  end
end
