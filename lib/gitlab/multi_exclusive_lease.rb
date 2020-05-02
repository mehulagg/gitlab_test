# frozen_string_literal: true

require 'securerandom'

module Gitlab
  class MultiExclusiveLease
    MultiLeaseAcquireResult = Struct.new(:success, :failure)

    def initialize(lease_prefix, timeout:)
      @lease_prefix = lease_prefix
      @timeout = timeout
    end

    def try_obtain(keys)
      lease_keys = {}.tap do |h|
        keys.each { |key| h[key] = "#{@lease_prefix}:#{key}" }
      end

      Gitlab::Redis::SharedState.with do |redis|
        redis.watch(lease_keys.values)

        lock_acquiring_failed = []
        unacquirable_leases(redis, lease_keys.values).each_with_index do |value, index|
          unless value.nil?
            lock_acquiring_failed << keys[index]
          end
        end

        lease_values = {}.tap do |h|
          keys.each { |key| h[key] = SecureRandom.uuid }
        end

        status = redis.multi do |transaction|
          transaction.mset(*lease_keys.values.zip(lease_values.values))
        end

        if bulk_lease_acquire_failed?(status)
          MultiLeaseAcquireResult.new(success: {}, failure: keys)
        else
          MultiLeaseAcquireResult.new(success: lease_values, failure: lock_acquiring_failed)
        end
      end
    end

    private

    def unacquirable_leases(redis, lease_keys)
      redis.mget(lease_keys)
    end

    def bulk_lease_acquire_failed?(status)
      status != ['OK']
    end
  end
end
