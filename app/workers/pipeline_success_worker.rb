# frozen_string_literal: true

class PipelineSuccessWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include PipelineQueue

  queue_namespace :pipeline_processing
  urgency :high

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(pipeline_id)
    Ci::Pipeline.find_by(id: pipeline_id).try do |pipeline|
      DailyCodeCoverageWorker.perform_async(pipeline.id)
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
