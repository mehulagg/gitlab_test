# frozen_string_literal: true

module Registrations
  class WelcomeController < ApplicationController
    layout 'onboarding'

    before_action :ensure_welcome_step_required

    def show
    end

    def update
      result = ::Users::SignupService.new(current_user, user_params).execute

      if result[:status] == :success
        if ::Gitlab.com? && show_onboarding_issues_experiment?
          track_experiment_event(:onboarding_issues, 'signed_up')
          record_experiment_user(:onboarding_issues)
        end

        return redirect_to new_users_sign_up_group_path if experiment_enabled?(:onboarding_issues) && show_onboarding_issues_experiment?

        set_flash_message! :notice, :signed_up
        redirect_to path_for_signed_in_user(current_user)
      else
        render :show
      end
    end

    private

    def ensure_welcome_step_required
      return redirect_to path_for_signed_in_user(current_user) if current_user.role_required?
    end

    def user_params
      params.require(:user).permit(:role, :setup_for_company)
    end

    def path_for_signed_in_user(user)
      if requires_confirmation?(user)
        users_almost_there_path
      else
        stored_location_for(user) || dashboard_projects_path
      end
    end

    def requires_confirmation?(user)
      return false if user.confirmed?
      return false if Feature.enabled?(:soft_email_confirmation)
      return false if experiment_enabled?(:signup_flow)

      true
    end
  end
end
