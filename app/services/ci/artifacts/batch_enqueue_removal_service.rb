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
      def execute
        in_lock(EXCLUSIVE_LOCK_KEY, ttl: LOCK_TIMEOUT, retries: 1) do
          loop_until(timeout: LOOP_TIMEOUT, limit: loop_limit) do |index|
            enqueue_batch_for_removal(index)
          end
        end
      end

      private

      def enqueue_batch_for_removal(index)
        batch = load_artifact_batch

        return false if batch.empty?

        ids = batch.map(&:id)
        Ci::DestroyBatchArtifactsWorker.bulk_perform_in(batch_delay(index), ids) # rubocop:disable Scalability/BulkPerformWithContext
        batch.update_all(pending_delete: true)
      end

      def load_artifact_batch
        artifact_batch = Ci::JobArtifact.expired(BATCH_SIZE)
        artifact_batch = artifact_batch.select(:id, :pending_delete)
        artifact_batch = artifact_batch.without_deleted
        artifact_batch = artifact_batch.unlocked if Gitlab::Ci::Features.destroy_only_unlocked_expired_artifacts_enabled?
        artifact_batch.load
      end

      def loop_limit
        (1000 * loop_factor).ceil
      end

      def batch_delay(batch_idx)
        batch_idx * 15.seconds
      end

      # rubocop:disable Gitlab/AvoidFeatureGet
      def loop_factor
        Feature
          .get(:ci_batch_artifacts_removal_loop_factor)
          .percentage_of_time_value
          .fdiv(100)
      end
      # rubocop:enable Gitlab/AvoidFeatureGet
    end
  end
end
