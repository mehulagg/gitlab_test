# frozen_string_literal: true

module EE
  module SnippetRepository
    extend ActiveSupport::Concern

    prepended do
      include ::Gitlab::Geo::ReplicableModel
      with_replicator Geo::SnippetRepositoryReplicator
    end

    class_methods do
      def replicables_for_geo_node
        # Not implemented yet. Should be responible for selective sync
        none
      end
    end
  end
end
