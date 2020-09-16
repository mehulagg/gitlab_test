# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InvitesController, :snowplow do
  let_it_be(:user) { create(:user) }
  let(:member) { create(:project_member, :invited, invite_email: user.email) }
  let(:raw_invite_token) { member.raw_invite_token }
  let(:project_members) { member.source.users }
  let(:md5_member_global_id) { Digest::MD5.hexdigest(member.to_global_id.to_s) }
  let(:params) { { id: raw_invite_token } }
  let(:snowplow_event) do
    {
      category: 'Growth::Acquisition::Experiment::InviteEmail',
      label: md5_member_global_id,
      property: group_type
    }
  end

  before do
    controller.instance_variable_set(:@member, member)
  end

  shared_examples 'tracks an event for the invitation reminders experiment' do |experimental_group, action|
    before do
      stub_experiment(invitation_reminders: true)
      allow(Gitlab::Experimentation).to receive(:enabled_for_attribute?).with(:invitation_reminders, member.invite_email).and_return(experimental_group)
    end

    let(:group_type) { experimental_group ? 'experimental_group' : 'control_group' }

    it "tracks the #{action} event for a user in the #{experimental_group ? 'experimental' : 'control'} group" do
      request

      expect_snowplow_event(
        category: 'Growth::Acquisition::Experiment::InvitationReminders',
        label: md5_member_global_id,
        property: group_type,
        action: action
      )
    end
  end

  describe 'GET #show' do
    subject(:request) { get :show, params: params }

    context 'when logged in' do
      before do
        sign_in(user)
      end

      it 'accepts user if invite email matches signed in user' do
        expect do
          request
        end.to change { project_members.include?(user) }.from(false).to(true)

        expect(response).to have_gitlab_http_status(:found)
        expect(flash[:notice]).to include 'You have been granted'
      end

      it 'forces re-confirmation if email does not match signed in user' do
        member.invite_email = 'bogus@email.com'

        expect do
          request
        end.not_to change { project_members.include?(user) }

        expect(response).to have_gitlab_http_status(:ok)
        expect(flash[:notice]).to be_nil
      end

      context 'when new_user_invite is not set' do
        it 'does not track the user as experiment group' do
          request

          expect_no_snowplow_event
        end
      end

      context 'when new_user_invite is experiment' do
        let(:params) { { id: raw_invite_token, new_user_invite: 'experiment' } }
        let(:group_type) { 'experiment_group' }

        it 'tracks the user as experiment group' do
          request

          expect_snowplow_event(snowplow_event.merge(action: 'opened'))
          expect_snowplow_event(snowplow_event.merge(action: 'accepted'))
        end
      end

      context 'when new_user_invite is control' do
        let(:params) { { id: raw_invite_token, new_user_invite: 'control' } }
        let(:group_type) { 'control_group' }

        it 'tracks the user as control group' do
          request

          expect_snowplow_event(snowplow_event.merge(action: 'opened'))
          expect_snowplow_event(snowplow_event.merge(action: 'accepted'))
        end
      end

      context 'when invite email is in the experimental group' do
        it_behaves_like 'tracks an event for the invitation reminders experiment', true, 'opened'
        it_behaves_like 'tracks an event for the invitation reminders experiment', true, 'accepted'
      end

      context 'when invite email is in the control group' do
        it_behaves_like 'tracks an event for the invitation reminders experiment', false, 'opened'
        it_behaves_like 'tracks an event for the invitation reminders experiment', false, 'accepted'
      end
    end

    context 'when not logged in' do
      context 'when inviter is a member' do
        it 'is redirected to a new session with invite email param' do
          request

          expect(response).to redirect_to(new_user_session_path(invite_email: member.invite_email))
        end
      end

      context 'when inviter is not a member' do
        let(:params) { { id: '_bogus_token_' } }

        it 'is redirected to a new session' do
          request

          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe 'POST #accept' do
    before do
      sign_in(user)
    end

    subject(:request) { post :accept, params: params }

    context 'when new_user_invite is not set' do
      it 'does not track an event' do
        request

        expect_no_snowplow_event
      end
    end

    context 'when new_user_invite is experiment' do
      let(:params) { { id: raw_invite_token, new_user_invite: 'experiment' } }
      let(:group_type) { 'experiment_group' }

      it 'tracks the user as experiment group' do
        request

        expect_snowplow_event(snowplow_event.merge(action: 'accepted'))
      end

      it_behaves_like 'tracks an event for the invitation reminders experiment', true, 'accepted'
      it_behaves_like 'tracks an event for the invitation reminders experiment', false, 'accepted'
    end

    context 'when new_user_invite is control' do
      let(:params) { { id: raw_invite_token, new_user_invite: 'control' } }
      let(:group_type) { 'control_group' }

      it 'tracks the user as control group' do
        request

        expect_snowplow_event(snowplow_event.merge(action: 'accepted'))
      end

      it_behaves_like 'tracks an event for the invitation reminders experiment', true, 'accepted'
      it_behaves_like 'tracks an event for the invitation reminders experiment', false, 'accepted'
    end
  end
end
