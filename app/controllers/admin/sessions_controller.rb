# frozen_string_literal: true

class Admin::SessionsController < ApplicationController
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
      authenticate_with_two_factor
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
    return invalid_login_redirect(user) unless user.can?(:log_in)

    if user_params[:otp_attempt].present? && session[:otp_user_id]
      authenticate_with_two_factor_via_otp(user)
    elsif user_params[:device_response].present? && session[:otp_user_id]
      authenticate_with_two_factor_via_u2f(user)
    elsif current_user && current_user.valid_password?(user_params[:password])
      prompt_for_two_factor(user)
    else
      locked_user_redirect(user)
    end
  end

  def authenticate_with_two_factor_via_otp(user)
    if valid_otp_attempt?(user)
      # Remove any lingering user data from login
      session.delete(:otp_user_id)

      user.save!

      if current_user_mode.enable_admin_mode!(skip_password_validation: true)
        redirect_to redirect_path, notice: _('Admin mode enabled')
      else
        invalid_login_redirect(user)
      end
    else
      user.increment_failed_attempts!
      Gitlab::AppLogger.info("Failed Login: user=#{user.username} ip=#{request.remote_ip} method=OTP")

      flash.now[:alert] = _('Invalid two-factor code.')
      prompt_for_two_factor(user)
    end
  end

  # Authenticate using the response from a U2F (universal 2nd factor) device
  def authenticate_with_two_factor_via_u2f(user)
    if U2fRegistration.authenticate(user, u2f_app_id, user_params[:device_response], session[:challenge])
      # Remove any lingering user data from login
      session.delete(:otp_user_id)
      session.delete(:challenge)

      if current_user_mode.enable_admin_mode!(skip_password_validation: true)
        redirect_to redirect_path, notice: _('Admin mode enabled')
      else
        invalid_login_redirect(user)
      end
    else
      user.increment_failed_attempts!
      Gitlab::AppLogger.info("Failed Login: user=#{user.username} ip=#{request.remote_ip} method=U2F")

      flash.now[:alert] = _('Authentication via U2F device failed.')
      prompt_for_two_factor(user)
    end
  end

  # Setup in preparation of communication with a U2F (universal 2nd factor) device
  # Actual communication is performed using a Javascript API
  # rubocop: disable CodeReuse/ActiveRecord
  def setup_u2f_authentication(user)
    key_handles = user.u2f_registrations.pluck(:key_handle)
    u2f = U2F::U2F.new(u2f_app_id)

    if key_handles.present?
      sign_requests = u2f.authentication_requests(key_handles)
      session[:challenge] ||= u2f.challenge
      gon.push(u2f: { challenge: session[:challenge], app_id: u2f_app_id,
                      sign_requests: sign_requests })
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def user_params
    params.permit(:password, :otp_attempt, :device_response)
  end

  def invalid_login_redirect(user)
    flash.now[:alert] = _('Invalid login or password')
    render :new
  end

  def prompt_for_two_factor(user)
    @user = user

    return invalid_login_redirect(user) unless user.can?(:log_in)

    session[:otp_user_id] = user.id
    setup_u2f_authentication(user)
    render 'admin/sessions/two_factor'
  end

  def valid_otp_attempt?(user)
    user.validate_and_consume_otp!(user_params[:otp_attempt]) ||
        user.invalidate_otp_backup_code!(user_params[:otp_attempt])
  end
end
