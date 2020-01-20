# frozen_string_literal: true

class ConsolidateCountersWorker
  include ApplicationWorker
  include Gitlab::ExclusiveLeaseHelpers

  feature_category_not_owned!

  # This TTL must be lower than the DELAY time
  # to ensure that we can initiate new processing
  # every <DELAY> time
  LOCK_TTL = 9.minutes
  DELAY = 10.minutes

  class << self
    # Schedule worker if none is scheduled
    def exclusively_perform_async(model_class, delay: DELAY)
      return if worker_scheduled?(model_class)

      schedule_worker_in(delay, model_class)
    end

    def free_schedule(model_class)
      Gitlab::Redis::SharedState.with do |redis|
        redis.del(redis_key_for(model_class))
      end
    end

    def worker_scheduled?(model_class)
      Gitlab::Redis::SharedState.with do |redis|
        redis.exists(redis_key_for(model_class))
      end
    end

    private

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

    lock_key = "consolidate-counters:processing:#{model_class}"

    in_lock(lock_key, ttl: LOCK_TTL) do
      model.slow_consolidate_counter_attributes!
    end

    # reschedule self if there are more events
    if !self.class.worker_scheduled?(model_class) && model.counter_events_available?
      self.class.exclusively_perform_async(model_class, delay: DELAY)
    end
  rescue Gitlab::ExclusiveLeaseHelpers::FailedToObtainLockError
    # a worker is already updating the counters
  end
end
