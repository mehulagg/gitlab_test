# frozen_string_literal: true

module Ci
  class CreateUpstreamDependentPipelineWorker
    include ::ApplicationWorker
    include ::PipelineQueue

    def perform(upstream_pipeline_id)
      ::Ci::Pipeline.find_by_id(upstream_pipeline_id).try do |upstream_pipeline|
        upstream_pipeline.project.downstream_projects.each do |target_project|
          begin
            ::Ci::CreateUpstreamDependentPipelineService
              .new(upstream_pipeline.project, upstream_pipeline.user)
              .execute(target_project)
          rescue ::Ci::CreateUpstreamDependentPipelineWorker::DownstreamPipelineCreationError => error
            logger.info "User #{upstream_pipeline.user.username} is not able to create a pipeline in #{target_project.full_path}: #{error.message}"
          end
        end
      end
    end
  end
end
