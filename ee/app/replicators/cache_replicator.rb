# frozen_string_literal: true

class CacheReplicator < Gitlab::Geo::Replicator
  event :invalidated

  protected

  def publish_invalidated(cache_key:)
    Geo::CacheInvalidationEventStore.new(cache_key).create!
  end
end
