# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::RemoveNonLdapMembershipService do
  describe '#execute', :clean_gitlab_redis_shared_state do
    include ExclusiveLeaseHelpers

    let_it_be(:group) { create(:group) }
    let_it_be(:user) { create(:user) }
    let(:lease_key) { "groups:remove_non_ldap_membership:#{group.id}" }

    subject { described_class.new(group, user) }

    context 'when we can obtain the lease' do
      it 'schedules the worker' do
        stub_exclusive_lease(lease_key, timeout: described_class::DEFAULT_LEASE_TIMEOUT)

        expect(::Groups::RemoveNonLdapMembersWorker).to receive(:perform_in).with(described_class::DEFAULT_LEASE_TIMEOUT, group.id, user.id).once

        subject.execute
      end
    end

    context "when we can't obtain the lease" do
      it 'does not schedule the worker' do
        stub_exclusive_lease_taken(lease_key, timeout: described_class::DEFAULT_LEASE_TIMEOUT)

        expect(::Groups::RemoveNonLdapMembersWorker).not_to receive(:perform_in)

        subject.execute
      end
    end
  end
end
