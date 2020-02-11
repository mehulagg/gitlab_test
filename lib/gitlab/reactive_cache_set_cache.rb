# frozen_string_literal: true

# Interface to the Redis-backed cache store to keep track of complete cache keys
# for a ReactiveCache resource.
module Gitlab
  class ReactiveCacheSetCache
    attr_reader :cache_prefix, :expires_in, :cache_type

    def initialize(cache_prefix, expires_in: 10.minutes)
      @cache_prefix = cache_prefix
      @expires_in = expires_in
      @cache_type = 'cache:gitlab'
    end

    def cache_key
      "#{cache_prefix}:set"
    end

    def write(value)
      with do |redis|
        redis.sadd(cache_key, value)

        redis.expire(cache_key, expires_in)
      end

      value
    end

    def values
      with { |redis| redis.smembers(cache_key) }
    end

    def clear_cache!
      values.each do |value|
        with { |redis| redis.del("#{cache_type}:#{value}") }
      end

      with { |redis| redis.del(cache_key) }
    end

    def include?(value)
      with { |redis| redis.sismember(cache_key, value) }
    end

    private

    def with(&blk)
      Gitlab::Redis::Cache.with(&blk) # rubocop:disable CodeReuse/ActiveRecord
    end
  end
end
