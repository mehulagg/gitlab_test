# frozen_string_literal: true

require "spec_helper"

RSpec.describe Groups::GroupMembersHelper do
  include MembersPresentation

  describe '.group_member_select_options' do
    let(:group) { create(:group) }

    before do
      helper.instance_variable_set(:@group, group)
    end

    it 'returns an options hash with skip_ldap' do
      expect(helper.group_member_select_options).to include(skip_ldap: false)
    end
  end

  describe '#members_data' do
    let(:current_user) { create(:user) }
    let(:group) { create(:group) }
    let(:group_member) { create(:group_member, group: group, created_by: current_user) }

    subject { helper.send('members_data', group, present_members([group_member])) }

    before do
      allow(helper).to receive(:can?).with(current_user, :owner_access, group).and_return(true)
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    it 'adds `using_license` property to hash' do
      allow(group_member.user).to receive(:using_gitlab_com_seat?).with(group).and_return(true)

      expect(subject.first).to include(using_license: true)
    end

    it 'adds `group_sso` property to hash' do
      allow(group_member.user).to receive(:group_sso?).with(group).and_return(true)

      expect(subject.first).to include(group_sso: true)
    end

    it 'adds `group_managed_account` property to hash' do
      allow(group_member.user).to receive(:group_managed_account?).and_return(true)

      expect(subject.first).to include(group_managed_account: true)
    end
  end
end
