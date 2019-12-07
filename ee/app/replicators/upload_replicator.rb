# frozen_string_literal: true

class UploadReplicator < Gitlab::Geo::Replicator
  event :deleted

  protected

  # @param [Upload] model
  def publish_deleted(model:)
    Geo::UploadDeletedEventStore.new(model).create!
  end
end
