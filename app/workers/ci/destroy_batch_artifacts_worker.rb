# frozen_string_literal: true

module Ci
  class Ci::DestroyBatchArtifactsService
    include ApplicationWorker

    feature_category :continuous_integration
    idempotent!

    def perform(artifact_ids)
      Ci::JobArtifact.id_in(artifact_ids).each(&:destroy)
    end
  end
end
