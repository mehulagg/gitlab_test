# frozen_string_literal: true

module SubscribableBannerHelper
  def gitlab_subscription_or_license
    return unless Feature.enabled?(:subscribable_banner, default_enabled: true)

    return decorated_subscription if display_subscription_banner?

    License.current
  end

  def gitlab_subscription_message_or_license_message
    return unless Feature.enabled?(:subscribable_banner, default_enabled: true)

    return subscription_message if display_subscription_banner?

    license_message
  end

  def display_subscription_banner!
    @display_subscription_banner = true
  end

  private

  def display_subscription_banner?
    @display_subscription_banner && ::Gitlab::CurrentSettings.should_check_namespace_plan?
  end
end
