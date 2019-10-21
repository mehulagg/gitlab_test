# frozen_string_literal: true

# Finder for retrieving project registries that that need a repository or
# wiki verification where projects belong to the specific shard using
# FDW queries.
#
# Basic usage:
#
#     Geo::ProjectRegistryPendingVerificationFinder
#       .new(current_node: Gitlab::Geo.current_node, shard_name: 'default', batch_size: 1000)
#       .execute.
module Geo
  class ProjectRegistryPendingVerificationFinder
    def initialize(current_node:, shard_name:, batch_size:)
      @current_node = Geo::Fdw::GeoNode.find(current_node.id)
      @shard_name = shard_name
      @batch_size = batch_size
    end

    def wikis
      pending_verification_registries(:wiki)
    end

    def repositories
      pending_verification_registries(:repository)
    end

    private

    attr_reader :current_node, :shard_name, :batch_size

    # rubocop:disable CodeReuse/ActiveRecord
    def pending_verification_registries(type)
      return Geo::ProjectRegistry.none unless valid_shard?

      Gitlab::Geo::Fdw::ProjectRegistryQueryBuilder
        .new(current_node.project_registries)
        .public_send("#{type}s_pending_verification")
        .within_shards(shard_name)
        .limit(batch_size)
    end
    # rubocop:enable CodeReuse/ActiveRecord

    def valid_shard?
      return true unless current_node.selective_sync_by_shards?

      current_node.selective_sync_shards.include?(shard_name)
    end
  end
end
