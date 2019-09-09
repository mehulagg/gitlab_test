# frozen_string_literal: true

module GitlabSubscriptions
  class ApplyTrialService
    def execute(apply_trial_params)
      response = subscription_app_client.create_trial_account(apply_trial_params)

      if response.success
        { success: true }
      else
        { success: false, errors: response.data&.errors }
      end
    end
  end

  private

  def subscription_app_client
    Gitlab::SubscriptionPortal::Client.new
  end
end
