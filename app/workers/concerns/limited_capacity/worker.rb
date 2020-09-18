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
#   def remaining_work_count(*args)
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

    included do
      sidekiq_options retry: 0
    end

    class_methods do
      def perform_with_capacity(*args)
        worker = self.new
        worker.remove_failed_jobs
        worker.report_prometheus_metrics(*args)
        required_jobs_count = worker.required_jobs_count(*args)

        arguments = Array.new(required_jobs_count) { args }
        self.bulk_perform_async(arguments) # rubocop:disable Scalability/BulkPerformWithContext
      end
    end

    def perform(*args)
      return unless has_capacity?

      job_counter.register(jid)
      perform_work(*args)
    rescue => exception
      raise
    ensure
      job_counter.remove(jid)
      report_prometheus_metrics
      re_enqueue(*args) unless exception
    end

    def perform_work(*args)
      raise NotImplementedError
    end

    def remaining_work_count(*args)
      raise NotImplementedError
    end

    def max_running_jobs
      raise NotImplementedError
    end

    def has_capacity?
      remaining_capacity > 0
    end

    def remaining_capacity
      [
        max_running_jobs - running_jobs_count - self.class.queue_size,
        0
      ].max
    end

    def has_work?(*args)
      remaining_work_count(*args) > 0
    end

    def remove_failed_jobs
      job_counter.clean_up
    end

    def report_prometheus_metrics(*args)
      running_jobs_gauge.set(prometheus_labels, running_jobs_count)
      remaining_work_gauge.set(prometheus_labels, remaining_work_count(*args))
      max_running_jobs_gauge.set(prometheus_labels, max_running_jobs)
    end

    def required_jobs_count(*args)
      [
        remaining_work_count(*args),
        remaining_capacity
      ].min
    end

    private

    def running_jobs_count
      job_counter.count
    end

    def job_counter
      strong_memoize(:job_counter) do
        JobCounter.new(self.class.name)
      end
    end

    def re_enqueue(*args)
      return unless has_capacity?
      return unless has_work?(*args)

      self.class.perform_async(*args)
    end

    def running_jobs_gauge
      strong_memoize(:running_jobs_gauge) do
        Gitlab::Metrics.gauge(:limited_capacity_worker_running_jobs, 'Number of running jobs')
      end
    end

    def max_running_jobs_gauge
      strong_memoize(:max_running_jobs_gauge) do
        Gitlab::Metrics.gauge(:limited_capacity_worker_max_running_jobs, 'Maximum number of running jobs')
      end
    end

    def remaining_work_gauge
      strong_memoize(:remaining_work_gauge) do
        Gitlab::Metrics.gauge(:limited_capacity_worker_remaining_work_count, 'Number of jobs waiting to be enqueued')
      end
    end

    def prometheus_labels
      { worker: self.class.name }
    end
  end
end
