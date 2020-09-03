# frozen_string_literal: true

module JiraConnectHelper
  def serialize_subscriptions(subscriptions)
    subscriptions.map do |subscription|
      {
        namespace: subscription.namespace.full_path,
        created_at: subscription.created_at,
        path: jira_connect_subscription_path(subscription)
      }
    end.to_json
  end
end
