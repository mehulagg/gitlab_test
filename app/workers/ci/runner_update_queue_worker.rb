# frozen_string_literal: true

module Ci
  class RunnerUpdateQueueWorker
    include ApplicationWorker
    include PipelineQueue

    queue_namespace :pipeline_processing
    feature_category :continuous_integration

    idempotent!

    def perform(runner_id)
      Ci::Runner.find_by_id(runner_id).try do |runner|
        Ci::Queueing::RedisMethod.new(runner).populate
      end
    end
  end
end
