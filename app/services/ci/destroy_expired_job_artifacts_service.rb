# frozen_string_literal: true

module Ci
  class DestroyExpiredJobArtifactsService
    include ::Gitlab::ExclusiveLeaseHelpers
    include ::Gitlab::LoopHelpers

    BATCH_SIZE = 100
    LOOP_TIMEOUT = 45.minutes
    LOOP_LIMIT = 1000
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
          destroy_batch(Ci::JobArtifact) || destroy_batch(Ci::PipelineArtifact)
        end
      end
    end

    private

    def destroy_batch(klass)
      artifacts = artifact_batch(klass).load

      return false if artifacts.empty?

      if klass == Ci::JobArtifact && parallel_destroy?
        parallel_destroy_batch(artifacts)
      else
        legacy_destroy_batch(artifacts)
      end
    end

    def artifact_batch(klass)
      if klass == Ci::JobArtifact
        klass.expired(BATCH_SIZE).unlocked.with_destroy_preloads
      else
        klass.expired(BATCH_SIZE)
      end
    end

    def parallel_destroy?
      ::Feature.enabled?(:ci_delete_objects)
    end

    def legacy_destroy_batch(artifacts)
      artifacts.each(&:destroy!)
    end

    def parallel_destroy_batch(artifacts)
      DeletedObject.bulk_import(artifacts)
      update_statistics_for(artifacts)
      Ci::JobArtifact.id_in(artifacts.map(&:id)).delete_all
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def update_statistics_for(artifacts)
      deltas = artifacts
        .group_by(&:project)
        .transform_values { |batch| -batch.sum(&:size) }

      Projects::BulkUpdateStatisticsService.new(
        deltas,
        statistic: Ci::JobArtifact.project_statistics_name
      ).execute
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
