# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::ScheduleNonLdapMembershipRemovalService do
  describe '#execute', :clean_gitlab_redis_shared_state do
    let_it_be(:group) { create(:group) }
    let_it_be(:user) { create(:user) }

    subject { described_class.new(group, user) }

    it 'schedules the worker' do
      expect(::Groups::RemoveNonLdapMembersWorker).to receive(:perform_async).with(group.id, user.id).once

      subject.execute
    end
  end
end
