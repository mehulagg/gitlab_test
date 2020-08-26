# frozen_string_literal: true

module Groups
  class ScheduleNonLdapMembershipRemovalService < Groups::BaseService
    include ExclusiveLeaseGuard

    DEFAULT_LEASE_TIMEOUT = 1.hour.to_i

    def execute
      group.update(params)

      try_obtain_lease do
        perform
      end
    end

    private

    def perform
      Groups::RemoveNonLdapMembersWorker.perform_in(DEFAULT_LEASE_TIMEOUT, group.id, current_user.id)
    end

    # Used by ExclusiveLeaseGuard
    def lease_timeout
      DEFAULT_LEASE_TIMEOUT
    end

    # Used by ExclusiveLeaseGuard
    def lease_key
      "groups:remove_non_ldap_membership:#{group.id}"
    end

    # Used by ExclusiveLeaseGuard
    # Overriding value as we never release the lease
    # before the timeout in order to prevent multiple
    # Groups::RemoveNonLdapMembersWorker to start in
    # a short span of time
    def lease_release?
      false
    end
  end
end
