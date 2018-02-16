module Geo
  class ProjectRegistryFinder < RegistryFinder
    def count_repositories
      current_node.projects.count
    end

    def count_wikis
      current_node.projects.with_wiki_enabled.count
    end

    def count_synced_repositories
      relation =
        if selective_sync?
          legacy_find_synced_repositories
        else
          find_synced_repositories
        end

      relation.count
    end

    def count_synced_wikis
      relation =
        if use_legacy_queries?
          legacy_find_synced_wikis
        else
          fdw_find_enabled_wikis
        end

      relation.count
    end

    def count_failed_repositories
      find_failed_project_registries('repository').count
    end

    def count_failed_wikis
      find_failed_project_registries('wiki').count
    end

    def find_failed_project_registries(type = nil)
      relation =
        if selective_sync?
          legacy_find_filtered_failed_projects(type)
        else
          find_filtered_failed_project_registries(type)
        end

      relation
    end

    def find_registries_to_verify
      # note that the checksum values get reset when the repository starts syncing
      Geo::ProjectRegistry.where('repository_checksum IS NULL OR wiki_checksum IS NULL')
    end

    def find_unsynced_projects(batch_size:)
      relation =
        if use_legacy_queries?
          legacy_find_unsynced_projects
        else
          fdw_find_unsynced_projects
        end

      relation.limit(batch_size)
    end

    def find_projects_updated_recently(batch_size:)
      relation =
        if use_legacy_queries?
          legacy_find_projects_updated_recently
        else
          fdw_find_projects_updated_recently
        end

      relation.limit(batch_size)
    end

    protected

    def find_synced_repositories
      Geo::ProjectRegistry.synced_repos
    end

    def find_filtered_failed_project_registries(type = nil)
      case type
      when 'repository'
        Geo::ProjectRegistry.failed_repos
      when 'wiki'
        Geo::ProjectRegistry.failed_wikis
      else
        Geo::ProjectRegistry.failed
      end
    end

    #
    # FDW accessors
    #

    def fdw_table
      Geo::Fdw::Project.table_name
    end

    # @return [ActiveRecord::Relation<Geo::Fdw::Project>]
    def fdw_find_unsynced_projects
      Geo::Fdw::Project.joins("LEFT OUTER JOIN project_registry ON project_registry.project_id = #{fdw_table}.id")
        .where(project_registry: { project_id: nil })
    end

    # @return [ActiveRecord::Relation<Geo::ProjectRegistry>]
    def fdw_find_enabled_wikis
      project_id_matcher =
        Geo::Fdw::ProjectFeature.arel_table[:project_id]
          .eq(Geo::ProjectRegistry.arel_table[:project_id])

      # Only read the IDs of projects with disabled wikis from the remote database
      not_exist = Geo::Fdw::ProjectFeature
        .where(wiki_access_level: [::ProjectFeature::DISABLED, nil])
        .where(project_id_matcher)
        .select('1')
        .exists
        .not

      Geo::ProjectRegistry.synced_wikis.where(not_exist)
    end

    # @return [ActiveRecord::Relation<Geo::Fdw::Project>]
    def fdw_find_projects_updated_recently
      Geo::Fdw::Project.joins("INNER JOIN project_registry ON project_registry.project_id = #{fdw_table}.id")
          .merge(Geo::ProjectRegistry.dirty)
          .merge(Geo::ProjectRegistry.retry_due)
    end

    #
    # Legacy accessors (non FDW)
    #

    # @return [ActiveRecord::Relation<Project>] list of unsynced projects
    def legacy_find_unsynced_projects
      legacy_left_outer_join_registry_ids(
        current_node.projects,
        Geo::ProjectRegistry.pluck(:project_id),
        Project
      )
    end

    # @return [ActiveRecord::Relation<Project>] list of projects updated recently
    def legacy_find_projects_updated_recently
      legacy_inner_join_registry_ids(
        current_node.projects,
        Geo::ProjectRegistry.dirty.retry_due.pluck(:project_id),
        Project
      )
    end

    # @return [ActiveRecord::Relation<Geo::ProjectRegistry>] list of synced projects
    def legacy_find_synced_repositories
      legacy_find_project_registries(Geo::ProjectRegistry.synced_repos)
    end

    # @return [ActiveRecord::Relation<Geo::ProjectRegistry>] list of synced projects
    def legacy_find_synced_wikis
      legacy_inner_join_registry_ids(
        current_node.projects.with_wiki_enabled,
          Geo::ProjectRegistry.synced_wikis.pluck(:project_id),
          Project
      )
    end

    # @return [ActiveRecord::Relation<Project>] list of synced projects
    def legacy_find_project_registries(project_registries)
      legacy_inner_join_registry_ids(
        current_node.projects,
        project_registries.pluck(:project_id),
        Project
      )
    end

    # @return [ActiveRecord::Relation<Project>] list of projects that sync has failed
    def legacy_find_filtered_failed_projects(type = nil)
      legacy_inner_join_registry_ids(
        find_filtered_failed_project_registries(type),
        current_node.projects.pluck(:id),
        Geo::ProjectRegistry,
        foreign_key: :project_id
      )
    end
  end
end
