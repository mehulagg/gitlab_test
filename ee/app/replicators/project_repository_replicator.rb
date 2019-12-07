# frozen_string_literal: true

class ProjectRepositoryReplicator < Gitlab::Geo::Replicator
  event :created
  event :deleted
  event :renamed
  event :updated
  event :reset_checksum

  def registry
    ::Geo::ProjectRegistry
  end

  protected

  # @param [Project] model
  def publish_created(model:)
    Geo::RepositoryCreatedEventStore.new(model).create!
  end

  # @param [Project] model
  # @param [Hash] params
  def publish_deleted(model:, **params)
    Geo::RepositoryDeletedEventStore.new(model, params).create!
  end

  # @param [Project] model
  # @param [Hash] params
  def publish_renamed(model:, **params)
    Geo::RepositoryRenamedEventStore.new(project, params).create!
  end

  # @param [Project] model
  # @param [Hash] params
  def publish_updated(model:, **params)
    Geo::RepositoryUpdatedEventStore.new(project, params).create!
  end

  def publish_reset_checksum(model:)
    Geo::ResetChecksumEventStore.new(model).create!
  end
end
