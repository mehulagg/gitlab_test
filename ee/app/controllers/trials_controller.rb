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
      render json: { ok: true }, status: :unprocessable_entity
    end
  end

  private

  def company_params
    params.permit(:company_name, :employees_quantity, :telephone_number, :trial_users_quantity, :country)
  end
end
