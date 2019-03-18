# frozen_string_literal: true

module Ci
  class CreateDownstreamProjectsPipelineWorker
    include ::ApplicationWorker
    include ::PipelineQueue

    def perform(upstream_pipeline_id)
      ::Ci::Pipeline.find_by_id(upstream_pipeline_id).try do |upstream_pipeline|
        upstream_pipeline.project.downstream_projects.each do |target_project|
          ::Ci::CreateDownstreamProjectPipelineService
            .new(upstream_pipeline.project, upstream_pipeline.user)
            .execute(target_project, upstream_pipeline)
        end
      end
    end
  end
end
