# frozen_string_literal: true

class ExpireBuildArtifactsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  # rubocop:disable Scalability/CronWorkerContext
  # This worker does not perform work scoped to a context
  include CronjobQueue
  # rubocop:enable Scalability/CronWorkerContext

  feature_category :continuous_integration

  def perform
    if Gitlab::Ci::Features.parallelize_artifacts_removal?
      Ci::ScheduleExpiredJobArtifactsService.new.execute
    else
      Ci::DestroyExpiredJobArtifactsService.new.execute
    end
  end
end
