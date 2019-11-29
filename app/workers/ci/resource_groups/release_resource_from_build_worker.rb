# frozen_string_literal: true

module Ci
  module ResourceGroups
    class ReleaseResourceFromBuildWorker
      include ApplicationWorker
      include PipelineQueue

      queue_namespace :pipeline_processing
      feature_category :continuous_integration

      def perform(build_id)
        Ci::Build.find_by_id(build_id).try do |build|
          Ci::ResourceGroups::ReleaseResourceFromBuildService.new(build.project, build.user)
            .execute(build)
        end
      end
    end
  end
end
