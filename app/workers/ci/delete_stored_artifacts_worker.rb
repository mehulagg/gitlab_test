# frozen_string_literal: true

module Ci
  class DeleteStoredArtifactsWorker
    include ::ApplicationWorker

    feature_category :continuous_integration
    worker_resource_boundary :memory
    worker_has_external_dependencies!

    feature_category :continuous_integration

    def perform(project_id, store_path, file_store, size)
      Project.find_by_id(project_id).try do |project|
        Ci::DeleteStoredArtifactsService.new(project).execute(store_path, file_store)

        UpdateProjectStatistics.update_project_statistics!(project, :build_artifacts_size, -size)
      end
    end
  end
end
