# frozen_string_literal: true

module Geo
  module Scheduler
    class SchedulerWorker
      include ApplicationWorker
      prepend Reenqueuer
      include GeoQueue
      include ::Gitlab::Geo::LogHelpers
      include ::Gitlab::Utils::StrongMemoize
      include GeoBackoffDelay

      DB_RETRIEVE_BATCH_SIZE = 1000
      LEASE_TIMEOUT = 10.minutes

      attr_reader :pending_resources, :scheduled_jobs

      def initialize
        @pending_resources = []
        @scheduled_jobs = []
      end

      # The scheduling works as the following:
      #
      # 1. Load a batch of IDs that we need to schedule (DB_RETRIEVE_BATCH_SIZE) into a pending list.
      # 2. Schedule them so that at most `max_capacity` are running at once.
      def perform
        log_info('Started scheduler')

        return quit(:node_disabled) unless node_enabled?
        return quit(:skipped)       if should_be_skipped?

        update_jobs_in_progress # set scheduled_jobs
        update_pending_resources
        schedule_jobs

        return quit(:no_more_work)  if no_more_work?

        true
      rescue => err
        log_error(err.message)

        raise err
      end

      private

      def quit(reason = :unknown)
        log_info("Quitting", reason: reason)

        false
      end

      def no_more_work?
        pending_resources.empty? && scheduled_jobs.empty?
      end

      # Subclasses should override this method to provide additional metadata
      # in log messages
      def worker_metadata
        {}
      end

      def base_log_data(message)
        super(message).merge(worker_metadata)
      end

      def db_retrieve_batch_size
        DB_RETRIEVE_BATCH_SIZE
      end

      def lease_timeout
        LEASE_TIMEOUT
      end

      def max_capacity
        raise NotImplementedError
      end

      def should_apply_backoff?
        pending_resources.empty?
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def take_batch(*arrays, batch_size: db_retrieve_batch_size)
        interleave(*arrays).uniq.compact.take(batch_size)
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # Combines the elements of multiple, arbitrary-length arrays into a single array.
      #
      # Each array is spread evenly over the resultant array.
      # The order of the original arrays is preserved within the resultant array.
      # In the case of ties between elements, the element from the first array goes first.
      # From https://stackoverflow.com/questions/15628936/ruby-equally-distribute-elements-and-interleave-merge-multiple-arrays/15639147#15639147
      #
      # For examples, see the specs in file_download_dispatch_worker_spec.rb
      def interleave(*arrays)
        elements = []
        coefficients = []
        arrays.each_with_index do |e, index|
          elements += e
          coefficients += interleave_coefficients(e, index)
        end

        combined = elements.zip(coefficients)
        combined.sort_by { |zipped| zipped[1] }.map { |zipped| zipped[0] }
      end

      # Assigns a position to each element in order to spread out arrays evenly.
      #
      # `array_index` is used to resolve ties between arrays of equal length.
      #
      # Examples:
      #
      # irb(main):006:0> interleave_coefficients(['a', 'b'], 0)
      # => [0.2499998750000625, 0.7499996250001875]
      # irb(main):027:0> interleave_coefficients(['a', 'b', 'c'], 0)
      # => [0.16666661111112963, 0.4999998333333889, 0.8333330555556481]
      # irb(main):007:0> interleave_coefficients(['a', 'b', 'c'], 1)
      # => [0.16699994433335189, 0.5003331665556111, 0.8336663887778704]
      def interleave_coefficients(array, array_index)
        (1..array.size).map do |i|
          (i - 0.5 + array_index / 1000.0) / (array.size + 1e-6)
        end
      end

      def update_jobs_in_progress
        status = Gitlab::SidekiqStatus.job_status(scheduled_job_ids)

        # SidekiqStatus returns an array of booleans: true if the job is still running, false otherwise.
        # For each entry, first use `zip` to make { job_id: 123 } -> [ { job_id: 123 }, bool ]
        # Next, filter out the jobs that have completed.
        @scheduled_jobs = @scheduled_jobs.zip(status).map { |(job, running)| job if running }.compact
      end

      def update_pending_resources
        @pending_resources = load_pending_resources
        set_backoff_time! if should_apply_backoff?
      end

      def schedule_jobs
        capacity = max_capacity
        num_to_schedule = [capacity - scheduled_job_ids.size, pending_resources.size].min
        num_to_schedule = 0 if num_to_schedule < 0

        to_schedule = pending_resources.shift(num_to_schedule)
        scheduled = to_schedule.map { |args| schedule_job(*args) }.compact
        scheduled_jobs.concat(scheduled)

        log_info("#schedule_jobs finished", enqueued: scheduled.length, pending: pending_resources.length, scheduled: scheduled_jobs.length, capacity: capacity)
      end

      def scheduled_job_ids
        scheduled_jobs.map { |data| data[:job_id] }
      end

      def current_node
        Gitlab::Geo.current_node
      end

      def node_enabled?
        # Only check every minute to avoid polling the DB excessively
        unless @last_enabled_check.present? && @last_enabled_check > 1.minute.ago
          @last_enabled_check = Time.now
          clear_memoization(:current_node_enabled)
        end

        strong_memoize(:current_node_enabled) do
          Gitlab::Geo.current_node_enabled?
        end
      end
    end
  end
end
