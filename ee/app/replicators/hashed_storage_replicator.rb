# frozen_string_literal: true

class HashedStorageReplicator < Gitlab::Geo::Replicator
  event :project_storage_migrated
  event :attachments_storage_migrated

  protected

  # @param [Project] model
  # @param [Hash] params
  def publish_project_storage_migrated(model:, **params)
    Geo::HashedStorageMigratedEventStore.new(model, params).create!
  end

  # @param [Project] model
  # @param [Hash] params
  def publish_attachments_storage_migrated(model:, **params)
    Geo::HashedStorageAttachmentsEventStore.new(model, params).create!
  end
end
