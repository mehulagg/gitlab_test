# frozen_string_literal: true

class ConsolidateCountersWorker
  include ApplicationWorker
  include Gitlab::ExclusiveLeaseHelpers

  LOCK_WAIT_TIME = 5.seconds
  LOCK_TTL = 10.seconds
  MAX_RETRIES = 10
  # TODO: maybe we don't need to accept "attribute" and instead
  # consolidate all the events for a given model

  def perform(model_class, model_id, attribute)
    model = model_class.constantize.find_by_id(model_id)
    return unless model

    # TODO: should we also include "attribute" in the lock?
    lock = [self.class.name, model_class, model_id].join(':')

    in_lock(lock, retries: MAX_RETRIES, ttl: LOCK_TTL, sleep_sec: LOCK_WAIT_TIME) do
      events = model.counter_events.where(attribute_name: attribute)
      # consolidate the events atomically:
      # * update attribute with the sum of the value of related events
      # * delete summed events
    end
  rescue Gitlab::ExclusiveLeaseHelpers::FailedToObtainLockError
    # TODO: what should we do here?
  end
end
