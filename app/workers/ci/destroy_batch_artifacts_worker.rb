# frozen_string_literal: true

module Ci
  class DestroyBatchArtifactsWorker
    include ApplicationWorker

    feature_category :continuous_integration
    idempotent!

    # rubocop: disable CodeReuse/ActiveRecord
    def perform(artifact_ids)
      Ci::JobArtifact
        .id_in(artifact_ids)
        .includes(:project, job: :project)
        .each(&:destroy)
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
