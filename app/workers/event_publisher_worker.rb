# frozen_string_literal: true

class EventPublisherWorker
  include ApplicationWorker

  feature_category_not_owned!
  weight 2
  urgency :high
  sidekiq_option retry: false
  idempotent! # because retries are disabled

  def perform(listener_name, event_name, data)
    event = event_name.constantize
    listener = listener_name.constantize

    listener.handle_event(event, data)
  end
end
