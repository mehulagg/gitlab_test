# frozen_string_literal: true

class ContainerRepositoryReplicator < Gitlab::Geo::Replicator
  event :updated

  def registry
    ::Geo::ContainerRepositoryRegistry
  end

  protected

  def publish_updated(repository:)
    # TODO: move EventStore logic to the replicator
    # This will allow us to have less classes to implement for each event
    Geo::ContainerRepositoryUpdatedEventStore.new(repository).create!
  end
end
