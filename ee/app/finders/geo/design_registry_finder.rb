# frozen_string_literal: true

module Geo
  class DesignRegistryFinder < RegistryFinder
    def count_syncable
      designs_repositories.count
    end

    def count_synced
      registries_for_design_repositories
        .merge(Geo::DesignRegistry.synced).count
    end

    def count_failed
      registries_for_design_repositories
        .merge(Geo::DesignRegistry.failed).count
    end

    def count_registry
      registries_for_design_repositories.count
    end

    def find_registries(params)
      designs_repositories = Geo::DesignRegistry
      designs_repositories = designs_repositories.with_state(params[:sync_status]) if params[:sync_status].present?
      designs_repositories = designs_repositories.with_search(params[:search]) if params[:search].present?
      designs_repositories
    end

    private

    def designs_repositories
      current_node.projects.inner_join_design_management
    end

    def registries_for_design_repositories
      designs_repositories
        .inner_join_design_registry
    end
  end
end
