# frozen_string_literal: true

module Ci
  class ScheduleExpiredJobArtifactsService
    include ::Gitlab::ExclusiveLeaseHelpers
    include ::Gitlab::LoopHelpers

    QUEUE_BATCH_SIZE = 1000
    WORKER_BATCH_SIZE = 100
    LOOP_TIMEOUT = 45.minutes
    LOOP_LIMIT = 100
    EXCLUSIVE_LOCK_KEY = 'expired_job_artifacts:destroy:lock'
    LOCK_TIMEOUT = 50.minutes

    ##
    # Destroy expired job artifacts on GitLab instance
    #
    # This destroy process cannot run for more than 45 minutes. This is for
    # preventing multiple `ExpireBuildArtifactsWorker` CRON jobs run concurrently,
    # which is scheduled at every hour.
    def execute
      in_lock(EXCLUSIVE_LOCK_KEY, ttl: LOCK_TIMEOUT, retries: 1) do
        loop_until(timeout: LOOP_TIMEOUT, limit: LOOP_LIMIT) do
          schedule_batch_destruction
        end
      end
    end

    private

    # rubocop:disable Scalability/BulkPerformWithContext
    def schedule_batch_destruction
      ::Gitlab::Ci::JobArtifactsExpirationQueue.pop(QUEUE_BATCH_SIZE) do |ids|
        ids.each_slice(WORKER_BATCH_SIZE).with_index do |batch, index|
          Ci::DestroyBatchArtifactsWorker
            .bulk_perform_in(5.seconds * index + 1, [[batch]])
        end
      end
    end
    # rubocop:enable Scalability/BulkPerformWithContext
  end
end
