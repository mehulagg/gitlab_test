# frozen_string_literal: true

module FeatureFlags
  class UpdateService < FeatureFlags::BaseService
    AUDITABLE_SCOPE_ATTRIBUTES_HUMAN_NAMES = {
      'active' => 'active state',
      'environment_scope' => 'environment scope'
    }.freeze

    def execute(feature_flag)
      ActiveRecord::Base.transaction do
        feature_flag.assign_attributes(params)

        permission_error = check_permissions(feature_flag)
        next error(permission_error) if permission_error

        audit_event = audit_event(feature_flag)

        if feature_flag.save
          save_audit_event(audit_event)

          success(feature_flag: feature_flag)
        else
          error(feature_flag.errors.full_messages)
        end
      end
    end

    private

    def audit_message(feature_flag)
      changes = changed_attributes_messages(feature_flag)
      changes += changed_scopes_messages(feature_flag)

      return if changes.empty?

      "Updated feature flag <strong>#{feature_flag.name}</strong>. " + changes.join(" ")
    end

    def changed_attributes_messages(feature_flag)
      feature_flag.changes.slice(*AUDITABLE_ATTRIBUTES).map do |attribute_name, changes|
        "Updated #{attribute_name} "\
        "from <strong>\"#{changes.first}\"</strong> to "\
        "<strong>\"#{changes.second}\"</strong>."
      end
    end

    def changed_scopes_messages(feature_flag)
      feature_flag.scopes.map do |scope|
        if scope.new_record?
          created_scope_message(scope)
        elsif scope.marked_for_destruction?
          deleted_scope_message(scope)
        else
          updated_scope_message(scope)
        end
      end.compact # updated_scope_message can return nil if nothing has been changed
    end

    def deleted_scope_message(scope)
      "Deleted rule <strong>#{scope.environment_scope}</strong>."
    end

    def updated_scope_message(scope)
      changes = scope.changes.slice(*AUDITABLE_SCOPE_ATTRIBUTES_HUMAN_NAMES.keys)
      return if changes.empty?

      message = "Updated rule <strong>#{scope.environment_scope}</strong> "
      message += changes.map do |attribute_name, change|
        name = AUDITABLE_SCOPE_ATTRIBUTES_HUMAN_NAMES[attribute_name]
        "#{name} from <strong>#{change.first}</strong> to <strong>#{change.second}</strong>"
      end.join(' ')

      message + '.'
    end

    def check_permissions(feature_flag)
      return unless permissions_enabled?

      feature_flag.scopes.each do |scope|
        next unless scope.changed? || scope.marked_for_destruction?

        environment_name =
          if scope.environment_scope_changed?
            scope.environment_scope_was
          else
            scope.environment_scope
          end

        unless environment_accessible_to_user?(environment_name)
          return permission_error_message(environment_name)
        end
      end

      nil
    end
  end
end
