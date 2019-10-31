# frozen_string_literal: true

class BuildQueueWorker
  include ApplicationWorker
  include PipelineQueue
  include CiMetrics

  queue_namespace :pipeline_processing
  feature_category :continuous_integration
  latency_sensitive_worker!
  worker_resource_boundary :cpu

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(build_id)
    Ci::Build.find_by(id: build_id).try do |build|
      count_pending_job(build)

      Ci::UpdateBuildQueueService.new.execute(build)
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
