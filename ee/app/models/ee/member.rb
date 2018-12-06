# frozen_string_literal: true

module EE
  module Member
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    attr_accessor :skip_notification

    class_methods do
      extend ::Gitlab::Utils::Override

      override :set_member_attributes
      def set_member_attributes(member, access_level, current_user: nil, expires_at: nil, ldap: false)
        super

        member.attributes = {
          skip_notification: ldap,
          ldap: ldap
        }
      end
    end

    override :notification_service
    def notification_service
      if ldap
        # LDAP users shouldn't receive notifications about membership changes
        ::EE::NullNotificationService.new
      else
        super
      end
    end
  end
end
