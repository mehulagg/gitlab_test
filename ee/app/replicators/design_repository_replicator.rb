# frozen_string_literal: true

class DesignRepositoryReplicator < Gitlab::Geo::Replicator
  def registry
    ::Geo::DesignRegistry
  end
end
