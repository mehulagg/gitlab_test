# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  layout 'checkout'

  def new
    return redirect_to dashboard_projects_path unless Feature.enabled?(:paid_signup_flow)
  end

  def payment_form
    response = client.payment_form_params(params[:id])
    render json: response[:data]
  end

  def payment_method
    response = client.payment_method(params[:id])
    render json: response[:data]
  end

  def create
    current_user.update(setup_for_company: params[:setup_for_company])
    result = Subscriptions::CreateService.new(current_user, customer_params, subscription_params).execute
    result[:location] = dashboard_projects_path
    render json: result
  end

  private

  def customer_params
    params.require(:customer).permit(:country, :address_1, :address_2, :city, :state, :zip_code, :company)
  end

  def subscription_params
    params.require(:subscription).permit(:plan_id, :payment_method_id, :quantity)
  end

  def client
    Gitlab::SubscriptionPortal::Client
  end
end
