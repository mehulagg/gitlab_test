# frozen_string_literal: true

# Usage:
#
# Worker that performs the tasks:
#
# class DummyWorker
#   include ApplicationWorker
#   include LimitedCapacity::Worker
#
#   def perform_work(*args)
#   end
#
#   def remaining_work
#     5
#   end
#
#   def max_running_jobs
#     25
#   end
# end
#
# Cron worker to fill the pool of regular workers:
#
# class ScheduleDummyCronWorker
#   include ApplicationWorker
#   include CronjobQueue
#
#   def perform(*args)
#     DummyWorker.perform_with_capacity(*args)
#   end
# end
#

module LimitedCapacity
  module Worker
    extend ActiveSupport::Concern
    include Gitlab::Utils::StrongMemoize

    class_methods do
      def perform_with_capacity(*args)
        worker = self.new
        worker.remove_completed_jobs_from_queue_set
        worker.report_prometheus_metrics

        required_jobs = [
          worker.remaining_work,
          worker.remaining_capacity
        ].min

        arguments = Array.new(required_jobs) { args }
        self.bulk_perform_async(arguments) # rubocop:disable Scalability/BulkPerformWithContext
      end
    end

    def perform(*args)
      register_running_job_for_queue
      return unless has_capacity? # In case the cron job started too many jobs

      perform_work(*args)
      re_enqueue(*args)
    ensure
      report_prometheus_metrics
      remove_job_from_running_for_queue
    end

    def remove_completed_jobs_from_queue_set
      completed_ids = Gitlab::SidekiqStatus.completed_jids(running_job_ids)

      remove_job_from_running_for_queue(completed_ids) if completed_ids.any?
    end

    def remaining_capacity
      [
        max_running_jobs - running_jobs - self.class.queue_size,
        0
      ].max
    end

    def has_capacity?
      remaining_capacity > 0
    end

    def has_work?
      remaining_work > 0
    end

    def perform_work(*args)
      raise NotImplementedError
    end

    def remaining_work
      raise NotImplementedError
    end

    def max_running_jobs
      raise NotImplementedError
    end

    def report_prometheus_metrics
      running_jobs_gauge.set({ worker: self.class.name }, running_jobs)
    end

    private

    def re_enqueue(*args)
      return unless can_re_enqueue?

      self.class.perform_async(*args)
    end

    def can_re_enqueue?
      has_capacity? && has_work?
    end

    def running_jobs
      with_redis do |redis|
        redis.scard(running_jobs_set_key).to_i
      end
    end

    def running_job_ids
      with_redis do |redis|
        redis.smembers(running_jobs_set_key)
      end
    end

    def register_running_job_for_queue(id = nil)
      with_redis do |redis|
        redis.sadd(running_jobs_set_key, id || jid)
      end
    end

    def remove_job_from_running_for_queue(id = nil)
      with_redis do |redis|
        redis.srem(running_jobs_set_key, id || jid)
      end
    end

    def running_jobs_set_key
      "worker:#{self.class.name.underscore}:running"
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def with_redis(&block)
      Gitlab::Redis::Queues.with(&block)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def running_jobs_gauge
      strong_memoize(:running_jobs_gauge) do
        Gitlab::Metrics.gauge(:limited_capacity_worker_running_jobs, 'Number of jobs running')
      end
    end
  end
end
