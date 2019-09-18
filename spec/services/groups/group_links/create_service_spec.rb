# frozen_string_literal: true

require 'spec_helper'

describe Groups::GroupLinks::CreateService, '#execute' do
  let(:parent_group_user) { create(:user) }
  let(:group_user) { create(:user) }
  let(:child_group_user) { create(:user) }

  set(:group_parent) { create(:group, :private) }
  set(:group) { create(:group, :private, parent: group_parent) }
  set(:group_child) { create(:group, :private, parent: group) }

  set(:shared_group_parent) { create(:group, :private) }
  set(:shared_group) { create(:group, :private, parent: shared_group_parent) }
  set(:shared_group_child) { create(:group, :private, parent: shared_group) }

  set(:project_parent) { create(:project, group: shared_group_parent) }
  set(:project) { create(:project, group: shared_group) }
  set(:project_child) { create(:project, group: shared_group_child) }

  let(:opts) do
    {
      shared_group_access: Gitlab::Access::DEVELOPER,
      expires_at: nil
    }
  end
  let(:user) { group_user }

  subject { described_class.new(group, user, opts) }

  it 'adds group to another group' do
    expect { subject.execute(shared_group) }.to change { group.group_group_links.count }.from(0).to(1)
  end

  it 'returns false if shared group is blank' do
    expect { subject.execute(nil) }.not_to change { group.group_group_links.count }
  end

  context 'share group with group' do
    before do
      group_parent.add_owner(parent_group_user)
      group.add_owner(group_user)
      group_child.add_owner(child_group_user)
    end

    context 'pre-checks' do
      it 'has does not have access to shared group or project' do
        [parent_group_user, group_user, child_group_user].each do |user|
          expect(Ability.allowed?(user, :read_group, shared_group_parent)).to be_falsey
          expect(Ability.allowed?(user, :read_group, shared_group)).to be_falsey
          expect(Ability.allowed?(user, :read_group, shared_group_child)).to be_falsey

          expect(Ability.allowed?(user, :read_project, project_parent)).to be_falsey
          expect(Ability.allowed?(user, :read_project, project)).to be_falsey
          expect(Ability.allowed?(user, :read_project, project_child)).to be_falsey
        end
      end
    end

    context 'group' do
      let(:user) { group_user }

      it 'create proper authorizations' do
        subject.execute(shared_group)

        expect(Ability.allowed?(user, :read_group, shared_group_parent)).to be_truthy # has_projects condition in GroupPolicy
        expect(Ability.allowed?(user, :read_group, shared_group)).to be_truthy
        expect(Ability.allowed?(user, :read_group, shared_group_child)).to be_truthy

        expect(Ability.allowed?(user, :read_project, project_parent)).to be_falsey
        expect(Ability.allowed?(user, :read_project, project)).to be_truthy
        expect(Ability.allowed?(user, :read_project, project_child)).to be_truthy
      end
    end

    context 'parent group' do
      let(:user) { parent_group_user }

      it 'create proper authorizations' do
        subject.execute(shared_group)

        expect(Ability.allowed?(user, :read_group, shared_group_parent)).to be_falsey
        expect(Ability.allowed?(user, :read_group, shared_group)).to be_truthy
        expect(Ability.allowed?(user, :read_group, shared_group_child)).to be_truthy

        expect(Ability.allowed?(user, :read_project, project_parent)).to be_falsey
        expect(Ability.allowed?(user, :read_project, project)).to be_falsey # TODO: implement inheritance for Projects
        expect(Ability.allowed?(user, :read_project, p)).to be_falsey # TODO: implement inheritance for Projects
      end
    end

    context 'child group' do
      let(:user) { child_group_user }

      it 'create proper authorizations' do
        expect(ProjectAuthorization.count).to be_zero
        expect(GroupGroupLink.count).to be_zero

        subject.execute(shared_group)

        expect(Ability.allowed?(user, :read_group, shared_group_parent)).to be_falsey
        expect(Ability.allowed?(user, :read_group, shared_group)).to be_falsey
        expect(Ability.allowed?(user, :read_group, shared_group_child)).to be_falsey

        expect(Ability.allowed?(user, :read_project, project_parent)).to be_falsey
        expect(Ability.allowed?(user, :read_project, project)).to be_falsey
        expect(Ability.allowed?(user, :read_project, project_child)).to be_falsey
      end
    end
  end
end
