# frozen_string_literal: true

class Admin::SessionsController < ApplicationController
  include AuthenticatesWithTwoFactor
  include InternalRedirect

  before_action :user_is_admin!

  # Mimic Devise resource attribute for some views (e.g. u2f auth)
  attr_accessor :resource

  def new
    if current_user_mode.admin_mode?
      redirect_to redirect_path, notice: _('Admin mode already enabled')
    else
      current_user_mode.request_admin_mode! unless current_user_mode.admin_mode_requested?
      store_location_for(:redirect, redirect_path)
    end
  end

  def create
    if two_factor_enabled_for_user?
      authenticate_with_two_factor(admin_mode: true)
    else
      if current_user_mode.enable_admin_mode!(password: user_params[:password])
        redirect_to redirect_path, notice: _('Admin mode enabled')
      else
        flash.now[:alert] = _('Invalid login or password')
        render :new
      end
    end
  rescue Gitlab::Auth::CurrentUserMode::NotRequestedError
    redirect_to new_admin_session_path, alert: _('Re-authentication period expired or never requested. Please try again')
  end

  def destroy
    current_user_mode.disable_admin_mode!

    redirect_to root_path, status: :found, notice: _('Admin mode disabled')
  end

  private

  def user_is_admin!
    render_404 unless current_user&.admin?
  end

  def two_factor_enabled_for_user?
    current_user&.two_factor_enabled?
  end

  def redirect_path
    redirect_to_path = safe_redirect_path(stored_location_for(:redirect)) || safe_redirect_path_for_url(request.referer)

    if redirect_to_path &&
        excluded_redirect_paths.none? { |excluded| redirect_to_path.include?(excluded) }
      redirect_to_path
    else
      admin_root_path
    end
  end

  def excluded_redirect_paths
    [new_admin_session_path, admin_session_path]
  end

  def user_params
    params.permit(:password, :otp_attempt, :device_response)
  end

  def valid_otp_attempt?(user)
    user.validate_and_consume_otp!(user_params[:otp_attempt]) ||
        user.invalidate_otp_backup_code!(user_params[:otp_attempt])
  end
end
