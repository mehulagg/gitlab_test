# frozen_string_literal: true

class Admin::SessionsController < ApplicationController
  include InternalRedirect

  before_action :user_is_admin!

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
      if user_params[:otp_attempt].present? && session[:otp_user_id]
        authenticate_with_two_factor_via_otp(current_user)
      elsif current_user && current_user.valid_password?(user_params[:password])
        prompt_for_two_factor(current_user)
      else
        flash.now[:alert] = _('Invalid login or password')
        render :new
      end
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

  def authenticate_with_two_factor
    user = self.resource = current_user
    return locked_user_redirect(user) unless user.can?(:log_in)

  end

  def user_params
    params.permit(:password, :otp_attempt, :device_response)
  end

  def prompt_for_two_factor(user)
    session[:otp_user_id] = user.id
    render 'admin/sessions/two_factor'
  end

  def authenticate_with_two_factor_via_otp(user)
    if valid_otp_attempt?(user)
      # Remove any lingering user data from login
      session.delete(:otp_user_id)

      user.save!

      if current_user_mode.enable_admin_mode!(skip_password_validation: true)
        redirect_to redirect_path, notice: _('Admin mode enabled')
      else
        flash.now[:alert] = _('Invalid login or password')
        render :new
      end
    else
      user.increment_failed_attempts!
      Gitlab::AppLogger.info("Failed Login: user=#{user.username} ip=#{request.remote_ip} method=OTP")
      flash.now[:alert] = _('Invalid two-factor code.')
      prompt_for_two_factor(user)
    end
  end

  def valid_otp_attempt?(user)
    user.validate_and_consume_otp!(user_params[:otp_attempt]) ||
        user.invalidate_otp_backup_code!(user_params[:otp_attempt])
  end
end
