# frozen_string_literal: true

require 'spec_helper'

describe Members::UpdateService do
  let(:project) { create(:project, :public) }
  let(:group) { create(:group, :public) }
  let(:current_user) { create(:user) }
  let(:member_user) { create(:user) }
  let(:permission) { :update }
  let(:member) { source.members_and_requesters.find_by!(user_id: member_user.id) }
  let(:params) do
    { access_level: Gitlab::Access::MAINTAINER, expires_at: Date.parse('2020-01-03') }
  end

  before do
    project.add_developer(member_user)
    group.add_developer(member_user)
  end

  shared_examples_for 'logs an audit event' do
    it do
      expect do
        described_class.new(current_user, params).execute(member, permission: permission)
      end.to change { SecurityEvent.count }.by(1)
    end
  end

  context 'when current user can update the given member' do
    before do
      project.add_maintainer(current_user)
      group.add_owner(current_user)
    end

    it_behaves_like 'logs an audit event' do
      let(:source) { project }
    end

    it_behaves_like 'logs an audit event' do
      let(:source) { group }
    end
  end

  context 'when updating the role of the member' do
    let!(:gitlab_subscription) { create(:gitlab_subscription, namespace: group) }
    let(:source) { group }
    let(:member_update) do
      described_class.new(current_user, access_level: Gitlab::Access::GUEST).execute(member)
    end

    before do
      allow(Gitlab::CurrentSettings.current_application_settings)
        .to receive(:should_check_namespace_plan?) { true }

      group.add_owner(current_user)
    end

    context 'to guest' do
      context 'with a gold plan' do
        before do
          gitlab_subscription.update_attribute(:hosted_plan, create(:gold_plan))
        end

        it 'skips the guest member from the max_seats_used counter' do
          expect { member_update }.to change { gitlab_subscription.reload.max_seats_used }.to(1)
        end
      end

      context 'with other plans' do
        [:bronze_plan, :silver_plan].each do |plan|
          before do
            gitlab_subscription.update_attribute(:hosted_plan, create(plan))
          end

          it 'includes the guest member in the max_seats_used counter' do
            expect { member_update }.to change { gitlab_subscription.reload.max_seats_used }.to(2)
          end
        end
      end
    end
  end
end
