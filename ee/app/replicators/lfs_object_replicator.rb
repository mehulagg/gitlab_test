# frozen_string_literal: true

class LfsObjectReplicator < Gitlab::Geo::Replicator
  event :deleted

  protected

  # @param [LfsObject] model
  def publish_deleted(model:)
    Geo::LfsObjectDeletedEventStore.new(model).create!
  end
end
