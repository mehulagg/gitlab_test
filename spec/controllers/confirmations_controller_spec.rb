# frozen_string_literal: true

require 'spec_helper'

describe ConfirmationsController do
  describe '#show' do
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      stub_application_setting(send_user_confirmation_email: true)
    end

    context 'when confirmation_token is valid' do
      before do
        @request.cookies[:confirmation_email_verification_token] = user.confirmation_email_verification_token
      end

      subject { get :show, params: { confirmation_token: user.confirmation_token } }

      let(:user) { create(:user, user_attributes) }
      let(:user_attributes) { { confirmation_token: 'token', confirmed_at: nil, confirmation_sent_at: Time.now } }

      it 'confirms the user' do
        subject

        expect(controller.current_user.confirmed?).to be_truthy
      end

      it 'authenticates the user when clicked within timerange' do
        subject

        expect(controller.current_user).to eq user
        expect(response).to redirect_to root_path
      end

      it 'creates an audit log record' do
        subject

        expect(SecurityEvent.last.details[:with]).to eq('confirmation-email')
      end

      it 'does not authenticate when link did not get clicked within timerange' do
        user

        travel_to(Time.now + 25.hours) do
          subject

          expect(controller.current_user).to be_nil
          expect(response).to redirect_to new_user_session_path(anchor: 'login-pane')
        end
      end

      it 'does not authenticate after the confirmation link got used once' do
        subject
        sign_out(user)

        expect(controller.current_user).to be_nil

        subject

        expect(controller.current_user).to be_nil
        expect(flash[:notice]).to eq "Your email address has been successfully confirmed."
      end

      it 'removes the confirmatil email verficiation cookie' do
        subject

        expect(cookies[:confirmation_email_verification_token]).to be_nil
      end

      context 'when cookie is not valid' do
        before do
          request.cookies[:confirmation_email_verification_token] = 'invalid'
        end

        it 'does not authenticate the user' do
          subject

          expect(controller.current_user).to be_nil
        end
      end

      context 'when user has two factor authentication enabled' do
        let(:user) { create(:user, :two_factor, user_attributes) }

        it 'does not authenticate user' do
          subject

          expect(controller.current_user).to be_nil
          expect(response).to redirect_to new_user_session_path(anchor: 'login-pane')
        end
      end
    end

    context 'when confirmation_token is invalid' do
      it 'does not authenticate the user' do
        get :show, params: { confirmation_token: 'invalid token' }
        expect(subject.current_user).to be_nil
      end
    end
  end
end
