# frozen_string_literal: true

module Ci
  module Artifacts
    class BatchEnqueueRemovalService
      include ::Gitlab::ExclusiveLeaseHelpers
      include ::Gitlab::LoopHelpers

      # When we will transition from Ci::DestroyExpiredJobArtifactsService
      # to this service we need to make sure that the two of them do not run concurrently.
      # Keeping the same lock key will enforce this.
      EXCLUSIVE_LOCK_KEY = 'expired_job_artifacts:destroy:lock'
      LOCK_TIMEOUT = 50.minutes

      BATCH_SIZE = 100
      LOOP_TIMEOUT = 45.minutes

      ##
      # Enqueue expired job artifacts for destruction
      #
      # This process cannot run for more than 45 minutes. This is for
      # preventing multiple `ExpireBuildArtifactsWorker` CRON jobs run concurrently,
      # which is scheduled at every hour.
      def execute(scope = nil)
        in_lock(EXCLUSIVE_LOCK_KEY, ttl: LOCK_TIMEOUT, retries: 1) do
          loop_until(timeout: LOOP_TIMEOUT, limit: loop_limit) do |index|
            enqueue_batch_for_removal(scope, index)
          end
        end
      end

      private

      def enqueue_batch_for_removal(scope, index)
        artifact_batch = scope.try(:limit, BATCH_SIZE) || Ci::JobArtifact.expired(BATCH_SIZE)
        artifact_batch = artifact_batch.select(:id, :enqueued_for_removal)
        artifact_batch = artifact_batch.for_removal
        artifact_batch = artifact_batch.unlocked if Feature.enabled?(:keep_latest_artifact_for_ref)
        artifact_batch = artifact_batch.load

        return false if artifact_batch.empty?

        ids = artifact_batch.map(&:id)
        Ci::DestroyJobArtifactsWorker.bulk_perform_in(batch_delay(index), ids) # rubocop:disable Scalability/BulkPerformWithContext
        artifact_batch.update_all(enqueued_for_removal: true)
      end

      def loop_limit
        1000
      end

      def batch_delay(batch_idx)
        batch_idx * 30.seconds
      end
    end
  end
end
