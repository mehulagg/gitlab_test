# frozen_string_literal: true

class WikiRepositoryReplicator < Gitlab::Geo::Replicator
  def registry
    ::Geo::ProjectRegistry # TODO WikiRegistry
  end
end
