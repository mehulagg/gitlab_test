# frozen_string_literal: true

module EE
  module Users
    module SelfManagedAdminNotify
      def reset_users_callouts(feature)
        ::UserCallout
          .with_feature_name(feature)
          .dismissed
          .destroy_all
      end

      def notify_admins
        return unless License.current&.active_user_count_threshold_reached?

        ::User.active.admins.each do |admin|
          ::LicenseMailer.approaching_active_user_count_limit(admin)
        end
      end
    end

    module CreateService
      extend ::Gitlab::Utils::Override
      include SelfManagedAdminNotify

      override :after_create_hook
      def after_create_hook(user, reset_token)
        super

        log_audit_event(user) if audit_required?

        # TODO: Move to a service or something
        if Gitlab.ee? && License.current.present?
          notify_admins
          reset_users_callouts(::UserCallout::ACTIVE_USER_COUNT_THRESHOLD)
        end
      end

      private

      def log_audit_event(user)
        ::AuditEventService.new(
          current_user,
          user,
          action: :create
        ).for_user.security_event
      end

      def audit_required?
        current_user.present?
      end
    end
  end
end
