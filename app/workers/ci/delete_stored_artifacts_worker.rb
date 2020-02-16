# frozen_string_literal: true

module Ci
  class DeleteStoredArtifactsWorker # rubocop:disable Scalability/IdempotentWorker
    include ::ApplicationWorker

    worker_resource_boundary :memory
    worker_has_external_dependencies!

    feature_category :continuous_integration

    def perform(project_id, store_path, file_store, size)
      project = Project.find_by_id(project_id)

      Ci::DeleteStoredArtifactsService.new(project).execute(store_path, file_store)
      UpdateProjectStatistics.update_project_statistics!(project, :build_artifacts_size, -size) if project
    end
  end
end
