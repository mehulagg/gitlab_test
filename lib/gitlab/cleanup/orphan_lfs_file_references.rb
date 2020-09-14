# frozen_string_literal: true

module Gitlab
  module Cleanup
    class OrphanLfsFileReferences
      include Gitlab::Utils::StrongMemoize

      attr_reader :project, :dry_run, :logger, :limit

      DEFAULT_REMOVAL_LIMIT = 1000

      def initialize(project, dry_run: true, logger: nil, limit: nil)
        @project = project
        @dry_run = dry_run
        @logger = logger || Gitlab::AppLogger
        @limit = limit
      end

      def run!
        # If this project is an LFS storage project (e.g. is the root of a fork
        # network), what it is safe to remove depends on the sum of its forks.
        # For now, skip cleaning up LFS for this complicated case
        if project.forks_count > 0 && project.lfs_storage_project == project
          log_info("Skipping orphan LFS check for #{project.name_with_namespace} as it is a fork root")
          return
        end

        log_info("Looking for orphan LFS files for project #{project.name_with_namespace}")

        remove_orphan_references
      end

      private

      def remove_orphan_references
        invalid_references = project.lfs_objects_projects.lfs_object_in(orphan_objects)

        if dry_run
          log_info("Found invalid references: #{invalid_references.count}")
        else
          count = 0
          invalid_references.each_batch(of: limit || DEFAULT_REMOVAL_LIMIT) do |relation|
            count += relation.delete_all
          end

          ProjectCacheWorker.perform_async(project.id, [], [:lfs_objects_size])

          log_info("Removed invalid references: #{count}")
        end
      end

      def orphan_objects
        # Get these first so racing with a git push can't remove any LFS objects
        oids = project.lfs_objects_oids

        repos = [
          project.repository,
          project.design_repository,
          project.wiki.repository
        ].select(&:exists?)

        repos.flat_map do |repo|
          oids -= repo.gitaly_blob_client.get_all_lfs_pointers.map(&:lfs_oid)
        end

        # The remaining OIDs are not used by any repository, so are orphans
        LfsObject.for_oids(oids)
      end

      def log_info(msg)
        logger.info("#{'[DRY RUN] ' if dry_run}#{msg}")
      end
    end
  end
end
