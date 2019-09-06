# frozen_string_literal: true

class TrialsController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create_lead
    result = GitlabSubscriptions::CreateLeadService.new.execute(company_params)

    if result[:success]
      render json: { ok: true }, status: :ok
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  private

  def authenticate_user!
    return if current_user

    redirect_to new_trial_registration_path, alert: I18n.t('devise.failure.unauthenticated')
  end

  def company_params
    params.permit(:company_name, :employees_quantity, :telephone_number, :trial_users_quantity, :country)
          .merge(extra_params)
  end

  def extra_params
    attrs = current_user.slice(:first_name, :last_name, :email)
    attrs[:uid] = current_user.id
    attrs[:skip_email_confirmation] = true
    attrs[:gitlab_com_trial] = true
    attrs[:provider] = 'gitlab'

    attrs
  end
end
