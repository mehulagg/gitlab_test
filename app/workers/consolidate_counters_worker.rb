# frozen_string_literal: true

class ConsolidateCountersWorker
  include ApplicationWorker
  include Gitlab::ExclusiveLeaseHelpers

  feature_category_not_owned!

  LOCK_WAIT_TIME = 5.seconds
  LOCK_TTL = 10.seconds
  MAX_RETRIES = 10

  def perform(model_class)
    model = model_class.constantize

    lock_key = "#{self.class.name}:#{model_class}"

    in_lock(lock_key, retries: MAX_RETRIES, ttl: LOCK_TTL, sleep_sec: LOCK_WAIT_TIME) do
      model.slow_consolidate_counter_attributes!
    end
  rescue Gitlab::ExclusiveLeaseHelpers::FailedToObtainLockError
    # a worker is already updating the counters
  end
end
