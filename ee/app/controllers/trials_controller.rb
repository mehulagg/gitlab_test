# frozen_string_literal: true

class TrialsController < ApplicationController
  layout 'trial'

  before_action :check_if_gl_com
  before_action :check_if_improved_trials_enabled
  before_action :authenticate_user!
  before_action :find_or_create_namespace, only: :apply

  def new
  end

  def select
  end

  def create_lead
    @lead_result = GitlabSubscriptions::CreateLeadService.new.execute({ trial_user: company_params })

    if @lead_result[:success]
      redirect_to select_trials_url
    else
      render :new
    end
  end

  def apply
    if @namespace.invalid?
      @apply_trial_errors = @namespace.errors.full_messages.to_sentence
      return render :select
    end

    trial_result = GitlabSubscriptions::ApplyTrialService.new.execute(apply_trial_params)

    if trial_result&.dig(:success)
      redirect_to group_url(@namespace, { trial: true })
    else
      @apply_trial_errors = trial_result&.dig(:errors)
      render :select
    end
  end

  private

  def authenticate_user!
    return if current_user

    redirect_to new_trial_registration_path, alert: I18n.t('devise.failure.unauthenticated')
  end

  def company_params
    params.permit(:company_name, :company_size, :phone_number, :number_of_users, :country)
          .merge(extra_params)
  end

  def extra_params
    attrs = current_user.slice(:first_name, :last_name)
    attrs[:work_email] = current_user.email
    attrs[:uid] = current_user.id
    attrs[:skip_email_confirmation] = true
    attrs[:gitlab_com_trial] = true
    attrs[:provider] = 'gitlab'

    attrs
  end

  def check_if_improved_trials_enabled
    render_404 unless Feature.enabled?(:improved_trial_signup)
  end

  def apply_trial_params
    gl_com_params = { gitlab_com_trial: true, sync_to_gl: true }

    {
      trial_user: params.permit(:namespace_id).merge(gl_com_params),
      uid: current_user.id
    }
  end

  def find_or_create_namespace
    @namespace = if params[:new_group_name].present?
                   create_group
                 elsif params[:namespace_id].present?
                   current_user.namespaces.find(params[:namespace_id])
                 end

    render_404 unless @namespace
  end

  def create_group
    name = params[:new_group_name]
    group = Groups::CreateService.new(current_user, name: name, path: name.parameterize).execute

    params[:namespace_id] = group.id

    group
  end
end
