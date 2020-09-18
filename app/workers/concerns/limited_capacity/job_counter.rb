# frozen_string_literal: true
module LimitedCapacity
  class JobCounter # rubocop:disable Scalability/IdempotentWorker
    include Gitlab::Utils::StrongMemoize

    def initialize(namespace)
      @namespace = namespace
    end

    def register(jid)
      _added, @count = with_redis do |redis|
        registrar.call(redis, jid)
        counter.call(redis)
      end
    end

    def remove(jid)
      _removed, @count = with_redis_pipeline do |redis|
        cleaner.call(redis, jid)
        counter.call(redis)
      end
    end

    def clean_up
      completed_jids = Gitlab::SidekiqStatus.completed_jids(running_jids)
      return unless completed_jids.any?

      _removed, @count = with_redis_pipeline do |redis|
        cleaner.call(redis, completed_jids)
        counter.call(redis)
      end
    end

    def count
      @count ||= with_redis { |redis| counter.call(redis) }
    end

    def running_jids
      with_redis do |redis|
        redis.smembers(counter_key)
      end
    end

    private

    attr_reader :namespace

    def counter_key
      "worker:#{namespace.to_s.underscore}:running"
    end

    def counter
      strong_memoize(:counter) do
        lambda do |redis|
          redis.scard(counter_key)
        end
      end
    end

    def cleaner
      strong_memoize(:cleaner) do
        lambda do |redis, keys|
          redis.srem(counter_key, keys)
        end
      end
    end

    def registrar
      strong_memoize(:registrar) do
        lambda do |redis, keys|
          redis.sadd(counter_key, keys)
        end
      end
    end

    def with_redis(&block)
      Gitlab::Redis::Queues.with(&block) # rubocop: disable CodeReuse/ActiveRecord
    end

    def with_redis_pipeline
      with_redis do |redis|
        redis.pipelined { yield(redis) }
      end
    end
  end
end
