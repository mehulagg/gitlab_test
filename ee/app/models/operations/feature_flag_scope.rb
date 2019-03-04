# frozen_string_literal: true

module Operations
  class FeatureFlagScope < ActiveRecord::Base
    prepend HasEnvironmentScope

    attribute :user, User.new

    self.table_name = 'operations_feature_flag_scopes'

    AUDITABLE_ATTRIBUTES = %s[active environment_scope]

    belongs_to :feature_flag

    validates :environment_scope, uniqueness: {
      scope: :feature_flag,
      message: "(%{value}) has already been taken"
    }

    validates :environment_scope,
      if: :default_scope?, on: :update,
      inclusion: { in: %w(*), message: 'cannot be changed from default scope' }

    before_destroy :prevent_destroy_default_scope, if: :default_scope?
    after_create :audit_event_create
    after_update :audit_event_update
    after_destroy :audit_event_destroy

    scope :ordered, -> { order(:id) }
    scope :enabled, -> { where(active: true) }
    scope :disabled, -> { where(active: false) }

    private

    def audit_event_create
      return true unless auditable_changes && user

      message = "Created feature flag scope <strong>#{environment_scope}</strong> with <strong>\"#{active}\"</strong>."

      ::AuditEventService.new(user, project, audit_event_base(message)).security_event
    end

    def audit_event_update
      return true unless auditable_changes && user

      message = "Updated feature flag "
      auditable_changes.each do |attribute, change|
        message += "#{attribute} of feature flag from #{change.first} to #{change.second}"
      end

      ::AuditEventService.new(user, project, audit_event_base(message)).security_event
    end

    def audit_event_destroy
      return true unless auditable_changes && user

      message = "Destroyed feature flag"

      ::AuditEventService.new(user, project, audit_event_base(message)).security_event
    end

    def auditable_changes
      @auditable_changes ||= previous_changes.select { |change| AUDITABLE_ATTRIBUTES.include?(change.key) }
    end

    def audit_event_base(message)
      {
        custom_message: message,
        target_id: self.id,
        target_type: self.class.name,
        target_details: self.name
      }
    end

    def default_scope?
      environment_scope_was == '*'
    end

    def prevent_destroy_default_scope
      raise ActiveRecord::ReadOnlyRecord, "default scope cannot be destroyed"
    end
  end
end
