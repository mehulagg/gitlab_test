# frozen_string_literal: true

module Groups
  class LdapMembershipService < Groups::BaseService
    include ExclusiveLeaseGuard

    DEFAULT_LEASE_TIMEOUT = 1.hour.to_i

    def execute
      try_obtain_lease do
        perform
      end

      group.update(params)
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
      "groups:ldap_membership:#{group.id}"
    end

    # Used by ExclusiveLeaseGuard
    # Overriding value as we never release the lease
    # before the timeout in order to prevent multiple
    # RootStatisticsWorker to start in a short span of time
    def lease_release?
      false
    end
  end
end
