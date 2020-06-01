# frozen_string_literal: true

module Ci
  module Queueing
    class RedisMethod
      include ExclusiveLeaseGuard

      attr_reader :runner

      POPULATE_LIMIT = 100
      FIND_LIMIT = 10
      EXPIRE_TIME = 3600.seconds
      LEASE_TIMEOUT = 60

      def initialize(runner)
        @runner = runner
      end

      def populate
        try_obtain_lease { unsafe_populate }
      end

      def find(&blk)
        valid = true

        # This is not the best order
        FIND_LIMIT.times do
          build_id, empty_queue = pop_next_build_id

          unless build_id
            if empty_queue
              # result is valid, as it is legitimate empty queue
              return Result.new(nil, valid)
            else
              # result is not valid, as it requires refresh
              Ci::RunnerUpdateQueueWorker.perform_async(runner.id)
              return Result.new(nil, false)
            end
          end

          # refresh queue
          build = Ci::Build.find_by_id(build_id.to_i)
          next unless build

          case result = yield(build)
          when :success
            return Result.new(build, true)
          when :conflict
            valid = false
            next
          when :skip
            next
          else
            raise ArgumentError, "invalid result: #{result}"
          end
        end

        # result is not valid, as we tested all items in current queue
        Result.new(nil, false)
      end

      private

      def pop_next_build_id
        with_redis do |redis|
          redis.multi do
            [
              redis.rpop(queue_list_name),
              redis.get(queue_empty_name)
            ]
          end
        end
      end

      def unsafe_populate
        # TODO: add exclusive lease
        # rubocop: disable CodeReuse/ActiveRecord
        build_ids = ::Ci::Queueing::FindMatchingJobs
          .new(queueing_params)
          .execute
          .limit(POPULATE_LIMIT)
          .ids
        # rubocop: enable CodeReuse/ActiveRecord

        with_redis do |redis|
          redis.multi do |multi|
            multi.del(queue_list_name, queue_empty_name)

            if build_ids.any?
              # push from right side, into left-side
              multi.lpush(queue_list_name, build_ids)
              multi.expire(queue_list_name, EXPIRE_TIME)
            else
              multi.set(queue_empty_name, "1")
              multi.expire(queue_empty_name, EXPIRE_TIME)
            end
          end
        end
      end

      def remove_build_id(id)
        # once processed we will the element from the head
        with_redis { |redis| redis.lrem(queue_list_name, 1, id) }
      end

      def queue_list_name
        @queue_list_name ||= "#{queue_prefix}:list"
      end

      def queue_empty_name
        @queue_empty_name ||= "#{queue_prefix}:empty"
      end

      def queue_prefix
        @queue_prefix ||= "runner:dynamic_build_queue:#{queueing_params.key}"
      end

      def queueing_params
        @queueing_params ||= runner.queueing_params
      end

      def with_redis
        Gitlab::Redis::SharedState.with do |redis|
          yield(redis)
        end
      end

      def lease_key
        @lease_key ||= "#{queue_prefix}:lease"
      end

      def lease_timeout
        LEASE_TIMEOUT
      end
    end
  end
end
