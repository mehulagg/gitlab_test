# frozen_string_literal: true

module Groups
  class ScheduleNonLdapMembershipRemovalService < Groups::BaseService
    def execute
      group.update(params).tap do |updated|
        perform if updated && !group.unlock_membership_to_ldap
      end
    end

    private

    def perform
      Groups::RemoveNonLdapMembersWorker.perform_async(group.id, current_user.id)
    end
  end
end
