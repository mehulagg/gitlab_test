# frozen_string_literal: true

require 'spec_helper'

describe Members::DestroyService do
  let(:current_user) { create(:user) }
  let(:member_user) { create(:user) }
  let(:group) { create(:group) }
  let(:member) { group.members.find_by(user_id: member_user.id) }

  before do
    group.add_owner(current_user)
    group.add_developer(member_user)
  end

  shared_examples_for 'logs an audit event' do
    it do
      expect { event }.to change { SecurityEvent.count }.by(1)
    end
  end

  context 'when current_user is present' do
    subject { described_class.new(current_user) }

    context 'with group membership via Group SAML' do
      let!(:saml_provider) { create(:saml_provider, group: group) }

      context 'with a SAML identity' do
        before do
          create(:group_saml_identity, user: member_user, saml_provider: saml_provider)
        end

        it 'cleans up linked SAML identity' do
          expect { subject.execute(member, {}) }.to change { member_user.reload.identities.count }.by(-1)
        end
      end

      context 'without a SAML identity' do
        it 'does not attempt to destroy unrelated identities' do
          create(:identity, user: member_user)

          expect { subject.execute(member, {}) }.not_to change(Identity, :count)
        end
      end
    end

    context 'audit events' do
      it_behaves_like 'logs an audit event' do
        let(:event) { subject.execute(member, {}) }
      end

      it 'does not log the audit event as a system event' do
        subject.execute(member, skip_authorization: true)
        details = AuditEvent.last.details

        expect(details[:system_event]).to be_nil
        expect(details[:reason]).to be_nil
      end
    end
  end

  context 'when current user is not present' do # ie, when the system initiates the destroy
    subject { described_class.new(nil) }

    context 'for members with expired access' do
      let(:member) { create(:project_member, user: member_user, expires_at: 1.day.ago) }

      context 'audit events' do
        it_behaves_like 'logs an audit event' do
          let(:event) { subject.execute(member, skip_authorization: true) }
        end

        it 'logs the audit event as a system event' do
          subject.execute(member, skip_authorization: true)
          details = AuditEvent.last.details

          expect(details[:system_event]).to be_truthy
          expect(details[:reason]).to include('access expired on')
        end
      end
    end
  end

  context 'updating max_seats_used counter' do
    before do
      allow(Gitlab::CurrentSettings.current_application_settings)
        .to receive(:should_check_namespace_plan?) { true }
    end

    let!(:gitlab_subscription) { create(:gitlab_subscription, namespace: group) }

    context 'when subscription is updated for the first time' do
      it 'calculates the new value for the max_seats_used counter' do
        expect(gitlab_subscription.max_seats_used).to eq(0)

        described_class.new(current_user).execute(member)

        expect(gitlab_subscription.reload.max_seats_used).to eq(1)
      end
    end
  end
end
