# frozen_string_literal: true

require 'spec_helper'

describe Registrations::ExperienceLevelsController do
  let_it_be(:user) { create(:user) }

  describe 'GET #show' do
    subject { get :show }

    context 'with an unauthenticated user' do
      it { is_expected.to have_gitlab_http_status(:redirect) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context 'with an authenticated user' do
      before do
        sign_in(user)
        stub_experiment_for_user(onboarding_issues: true)
      end

      it { is_expected.to have_gitlab_http_status(:ok) }
      it { is_expected.to render_template(:show) }

      context 'when not part of the onboarding issues experiment' do
        before do
          stub_experiment_for_user(onboarding_issues: false)
        end

        it { is_expected.to have_gitlab_http_status(:not_found) }
      end
    end
  end

  describe 'PUT/PATCH #update' do
    subject { patch :update, params: params }

    let_it_be(:namespace) { create(:group, path: 'group-path' ) }

    let(:params) { {} }

    context 'with an unauthenticated user' do
      it { is_expected.to have_gitlab_http_status(:redirect) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context 'with an authenticated user' do
      before do
        sign_in(user)
        stub_experiment_for_user(onboarding_issues: true)
      end

      context 'when not part of the onboarding issues experiment' do
        before do
          stub_experiment_for_user(onboarding_issues: false)
        end

        it { is_expected.to have_gitlab_http_status(:not_found) }
      end

      context 'when user is successfully updated' do
        it { is_expected.to set_flash[:message].to('Welcome! You have signed up successfully.') }

        context 'when no experience_level is sent' do
          before do
            user.user_preference.update_attribute(:experience_level, :novice)
          end

          it 'will unset the user’s experience level' do
            expect { subject }.to change { user.reload.experience_level }.to(nil)
          end
        end

        context 'when an expected experience level is sent' do
          let(:params) { { experience_level: :novice } }

          it 'sets the user’s experience level' do
            expect { subject }.to change { user.reload.experience_level }.to('novice')
          end
        end

        context 'when an unexpected experience level is sent' do
          let(:params) { { experience_level: :nonexistent } }

          it 'raises an exception' do
            expect { subject }.to raise_error(ArgumentError, "'nonexistent' is not a valid experience_level")
          end
        end

        context 'when a namespace_path is sent' do
          let(:params) { { namespace_path: namespace.to_param } }

          it { is_expected.to have_gitlab_http_status(:redirect) }
          it { is_expected.to redirect_to(group_path(namespace)) }
        end

        context 'when no namespace_path is sent' do
          it { is_expected.to have_gitlab_http_status(:redirect) }
          it { is_expected.to redirect_to(user_path(user)) }
        end
      end

      context 'when user update fails' do
        before do
          allow_any_instance_of(User).to receive(:save).and_return(false)
        end

        it { is_expected.to render_template(:show) }
      end
    end
  end
end
