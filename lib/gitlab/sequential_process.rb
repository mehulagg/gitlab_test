# frozen_string_literal: true

module Gitlab
  class SequentialProcess
    attr_reader :key_group

    def initialize(key_group, ttl, class_name, class_args, method_name)
      raise ArgumentError unless key_group && ttl && method_name && method_name

      @key_group, @ttl, @class_name, @class_args, @method_name = key_group, ttl, class_name, class_args, method_name
    end

    def execute(new_queue)
      lease = Gitlab::ExclusiveLease.new(lock_key, timeout: ttl)

      unless uuid = lease.try_obtain
        ##
        # If there is the other process has already been working on the
        # expensive process, the system remembers the argument to be processed
        # later and finishes the process immediataly.
        Redis.push_to_queue(queue_key, new_queue) if new_queue
        return :later
      end

      ##
      # Execute an expensive process with stacked args
      all_args = (stacked_queues + [new_queue]).compact
      class_name.new(*class_args).public_send(method_name, all_args)

      # if we have anything added new to the queue
      # force refresh of the queue asynchronously
      # it will only be executed after in_lock succeeds,
      # otherwise it should raise exception
      if anything_in_queue?
        SequentialProcessWorker.perform_async(key_group, ttl, class_name, class_args, method_name)
      end

      :done
    ensure
      Gitlab::ExclusiveLease.cancel(lock_key, uuid) if uuid
    end

    def lock_key
      "sequential_process:lock:#{key_group}"
    end

    def queue_key
      "sequential_process:queue:#{key_group}"
    end

    def stacked_queues
      Redis.pop_all_from_queue(queue_key)
    end

    def anything_in_queue?
      Redis.len(queue_key) > 0
    end
  end
end
