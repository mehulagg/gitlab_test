# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RegistrationsController do
  let_it_be(:user) { create(:user) }

  describe '#create' do
    context 'when the user opted-in' do
      let(:user_params) { { user: attributes_for(:user, email_opted_in: '1') } }

      it 'sets the rest of the email_opted_in fields' do
        post :create, params: user_params
        user = User.find_by_username!(user_params[:user][:username])
        expect(user.email_opted_in).to be_truthy
        expect(user.email_opted_in_ip).to be_present
        expect(user.email_opted_in_source).to eq('GitLab.com')
        expect(user.email_opted_in_at).not_to be_nil
      end
    end

    context 'when the user opted-out' do
      let(:user_params) { { user: attributes_for(:user, email_opted_in: '0') } }

      it 'does not set the rest of the email_opted_in fields' do
        post :create, params: user_params
        user = User.find_by_username!(user_params[:user][:username])
        expect(user.email_opted_in).to be_falsey
        expect(user.email_opted_in_ip).to be_blank
        expect(user.email_opted_in_source).to be_blank
        expect(user.email_opted_in_at).to be_nil
      end
    end

    context 'when reCAPTCHA experiment enabled' do
      it "logs a 'User Created' message including the experiment state" do
        user_params = { user: attributes_for(:user) }
        allow_any_instance_of(EE::RecaptchaExperimentHelper).to receive(:show_recaptcha_sign_up?).and_return(true)

        expect(Gitlab::AppLogger).to receive(:info).with(/\AUser Created: .+experiment_growth_recaptcha\?true\z/).and_call_original

        post :create, params: user_params
      end
    end
  end

  describe '#welcome' do
    subject { get :welcome }

    before do
      sign_in(user)
    end

    it 'renders the checkout layout' do
      expect(subject).to render_template(:checkout)
    end
  end

  describe '#update_registration' do
    before do
      sign_in(user)
    end

    subject(:update_registration) { patch :update_registration, params: { user: { role: 'software_developer', setup_for_company: 'false' } } }

    describe 'redirection' do
      it { is_expected.to redirect_to dashboard_projects_path }

      context 'when part of the onboarding issues experiment' do
        before do
          stub_experiment_for_user(onboarding_issues: true)
        end

        it { is_expected.to redirect_to new_users_sign_up_group_path }

        context 'when in subscription flow' do
          before do
            allow(controller.helpers).to receive(:in_subscription_flow?).and_return(true)
          end

          it { is_expected.not_to redirect_to new_users_sign_up_group_path }
        end

        context 'when in invitation flow' do
          before do
            allow(controller.helpers).to receive(:in_invitation_flow?).and_return(true)
          end

          it { is_expected.not_to redirect_to new_users_sign_up_group_path }
        end

        context 'when in trial flow' do
          before do
            allow(controller.helpers).to receive(:in_trial_flow?).and_return(true)
          end

          it { is_expected.not_to redirect_to new_users_sign_up_group_path }
        end
      end
    end

    describe 'recording the user and tracking events for the onboarding issues experiment' do
      using RSpec::Parameterized::TableSyntax

      let(:on_gitlab_com) { false }
      let(:experiment_enabled) { false }
      let(:experiment_enabled_for_user) { false }
      let(:in_subscription_flow) { false }
      let(:in_invitation_flow) { false }
      let(:in_oauth_flow) { false }
      let(:in_trial_flow) { false }

      before do
        allow(::Gitlab).to receive(:com?).and_return(on_gitlab_com)
        stub_experiment(onboarding_issues: experiment_enabled)
        stub_experiment_for_user(onboarding_issues: experiment_enabled_for_user)
        allow(controller.helpers).to receive(:in_subscription_flow?).and_return(in_subscription_flow)
        allow(controller.helpers).to receive(:in_invitation_flow?).and_return(in_invitation_flow)
        allow(controller.helpers).to receive(:in_oauth_flow?).and_return(in_oauth_flow)
        allow(controller.helpers).to receive(:in_trial_flow?).and_return(in_trial_flow)
      end

      context 'when on GitLab.com' do
        let(:on_gitlab_com) { true }

        context 'and the onboarding issues experiment is enabled' do
          let(:experiment_enabled) { true }

          context 'and we’re not in the subscription, invitation, oauth, or trial flow' do
            where(:experiment_enabled_for_user, :group_type) do
              true  | :experimental
              false | :control
            end

            with_them do
              it 'adds the user to the experiments table with the correct group_type' do
                expect(::Experiment).to receive(:add_user).with(:onboarding_issues, group_type, user)

                update_registration
              end

              it 'tracks a signed_up event' do
                expect(Gitlab::Tracking).to receive(:event).with(
                  'Growth::Conversion::Experiment::OnboardingIssues',
                  'signed_up',
                  label: anything,
                  property: "#{group_type}_group"
                )

                update_registration
              end
            end
          end

          context 'but we’re in the subscription, invitation, oauth, or trial flow' do
            where(:in_subscription_flow, :in_invitation_flow, :in_oauth_flow, :in_trial_flow) do
              true  | false | false | false
              false | true  | false | false
              false | false | true  | false
              false | false | false | true
            end

            with_them do
              it 'does not add the user to the experiments table' do
                expect(::Experiment).not_to receive(:add_user)

                update_registration
              end

              it 'does not track a signed_up event' do
                expect(Gitlab::Tracking).not_to receive(:event)

                update_registration
              end
            end
          end
        end
      end

      context 'when not on GitLab.com, regardless of whether or not the experiment is enabled' do
        where(experiment_enabled: [true, false])

        with_them do
          it 'does not add the user to the experiments table' do
            expect(::Experiment).not_to receive(:add_user)

            update_registration
          end

          it 'does not track a signed_up event' do
            expect(Gitlab::Tracking).not_to receive(:event)

            update_registration
          end
        end
      end
    end
  end
end
