# frozen_string_literal: true

class TrialRegistrationsController < RegistrationsController
  layout 'trial'

  before_action :check_if_gl_com
  before_action :set_redirect_url, only: [:new]

  def new
  end

  private

  def set_redirect_url
    store_location_for(:user, new_trial_url)
  end

  def sign_up_params
    if params[:user]
      params.require(:user).permit(:first_name, :last_name, :username, :email, :password, :skip_confirmation)
    else
      {}
    end
  end

  def resource
    @resource ||= Users::BuildService.new(current_user, sign_up_params).execute(skip_authorization: true)
  end

  def check_if_gl_com
    render_404 unless Gitlab.com?
  end
end
