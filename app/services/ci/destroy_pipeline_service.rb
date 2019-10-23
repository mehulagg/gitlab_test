# frozen_string_literal: true

module Ci
  class DestroyPipelineService < BaseService
    def execute(pipeline)
      raise Gitlab::Access::AccessDeniedError unless can?(current_user, :destroy_pipeline, pipeline)

      Ci::ExpirePipelineCacheService.new.execute(pipeline, delete: true)

      pipeline.artifacts.find_each do |build|
        build.job_artifacts.find_each do |artifact|
          artifact.remove_file!
          artifact.save
        end
      end

      pipeline.destroy!
    end
  end
end
