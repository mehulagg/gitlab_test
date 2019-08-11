# frozen_string_literal: true

class ConfirmationsController < Devise::ConfirmationsController
  include AcceptsPendingInvitations

  AUTHENTICATE_AFTER_CONFIRMATION_EXPIRATION = 24.hours.freeze

  def almost_there
    flash[:notice] = nil
    render layout: "devise_empty"
  end

  protected

  def after_resending_confirmation_instructions_path_for(resource)
    stored_location_for(resource) || dashboard_projects_path
  end

  def after_confirmation_path_for(resource_name, resource)
    accept_pending_invitations

    if should_sign_in?
      sign_in(resource)
      AuditEventService.new(resource, resource, with: 'confirmation-email').for_authentication.security_event
    end

    # incoming resource can either be a :user or an :email
    if signed_in?(:user)
      after_sign_in(resource)
    else
      Gitlab::AppLogger.info("Email Confirmed: username=#{resource.username} email=#{resource.email} ip=#{request.remote_ip}")
      flash[:notice] = flash[:notice] + _(" Please sign in.")
      new_session_path(:user, anchor: 'login-pane')
    end
  end

  def after_sign_in(resource)
    after_sign_in_path_for(resource)
  end

  private

  def should_sign_in?
    resource_name == :user &&
      !user_signed_in? &&
      !resource.two_factor_enabled? &&
      resource.confirmation_sent_at &&
      Time.now <= resource.confirmation_sent_at + AUTHENTICATE_AFTER_CONFIRMATION_EXPIRATION
  end
end

ConfirmationsController.prepend_if_ee('EE::ConfirmationsController')
