# frozen_string_literal: true

module EE
  module Member
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    class_methods do
      extend ::Gitlab::Utils::Override

      STATISTICS_BATCH_SIZE = 10_000

      override :set_member_attributes
      def set_member_attributes(member, access_level, current_user: nil, expires_at: nil, ldap: false)
        super

        member.attributes = {
          ldap: ldap
        }
      end

      def roles_stats
        @roles_stats ||= generate_roles_stats
      end

      private

      # Get amount of users with highest role they have in a Group or Project.
      # If John is a developer in one project but a maintainer in another and a
      # developer in a Group he will be counted once as maintainer. This is
      # needed to count users who don't use functionality available to higher
      # roles only.
      #
      # Example of result:
      #  [{10=>4},
      #  {30=>10},
      #  {40=>9},
      #  {50=>1}]
      def generate_roles_stats(batch_size: STATISTICS_BATCH_SIZE)
        stats = Hash.new(0)

        (1..::User.maximum(:id).to_i).step(batch_size) do |step|
          roles_stats_in_batches(start_id: step, batch_size: batch_size).each do |stat|
            stats[stat['access_level']] += stat['amount']
          end
        end

        stats
      end

      def roles_stats_in_batches(start_id: 1, batch_size: STATISTICS_BATCH_SIZE)
        highest_access = ::Member
          .select('user_id, MAX(access_level) AS access_level')
          .where(user_id: [start_id..(start_id + batch_size)])
          .group(:user_id)

        ::Member
          .select('access_level, COUNT(*) AS amount')
          .from(highest_access)
          .group(:access_level)
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

    def sso_enforcement
      unless ::Gitlab::Auth::GroupSaml::MembershipEnforcer.new(group).can_add_user?(user)
        errors.add(:user, 'is not linked to a SAML account')
      end
    end
  end
end
