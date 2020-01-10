# frozen_string_literal: true

class ConsolidateCountersWorker
  include ApplicationWorker
  include Gitlab::ExclusiveLeaseHelpers

  feature_category_not_owned!

  LOCK_WAIT_TIME = 5.seconds
  LOCK_TTL = 10.seconds
  MAX_RETRIES = 10

  # Ensure that for the time being (delay) no other workers are
  # scheduled.
  class << self
    def perform_exclusively_in(delay, model_class)
      unless worker_scheduled?(model_class)
        schedule_worker_in(delay, model_class)
      end
    end

    def free_schedule(model_class)
      Gitlab::Redis::SharedState.with do |redis|
        redis.del(redis_key_for(model_class))
      end
    end

    private

    def worker_scheduled?(model_class)
      Gitlab::Redis::SharedState.with do |redis|
        redis.exists(redis_key_for(model_class))
      end
    end

    def schedule_worker_in(delay, model_class)
      Gitlab::Redis::SharedState.with do |redis|
        redis.set(redis_key_for(model_class), 1, ex: delay)
      end

      perform_in(delay, model_class)
    end

    def redis_key_for(model_class)
      "consolidate-counters:scheduling:#{model_class}"
    end
  end

  def perform(model_class)
    model = model_class.constantize

    lock_key = "#{self.class.name}:#{model_class}"

    in_lock(lock_key, retries: MAX_RETRIES, ttl: LOCK_TTL, sleep_sec: LOCK_WAIT_TIME) do
      model.slow_consolidate_counter_attributes!
    end

    self.class.free_schedule(model_class)
  rescue Gitlab::ExclusiveLeaseHelpers::FailedToObtainLockError
    # a worker is already updating the counters
  end
end
