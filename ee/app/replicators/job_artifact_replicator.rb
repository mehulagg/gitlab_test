# frozen_string_literal: true

class JobArtifactReplicator < Gitlab::Geo::Replicator
  event :deleted

  protected

  # @param [Ci::JobArtifact] model
  def publish_deleted(model:)
    Geo::JobArtifactDeletedEventStore.new(model).create!
  end
end
