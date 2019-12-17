# frozen_string_literal: true

module Gitlab
  module Geo
    module Trackable
      class ProjectRepository
        attr_accessor :registry

        def initialize(replicable_id)
          @registry = Geo::ProjectRegistry.safe_create_of_find_by(project_id: replicable_id)
        end

        def destroy!
          # TODO cannot destroy dual purpose project + wiki registry
        end

        def repository_path
          replicable.repository.disk_path
        end

        def repository_shard
          replicable.project_repository.shard.name
        end

        def

        private

        def replicable
          @replicable ||= Project.find(registry.replicable_id)
        end



        # project_id

        # #last_repository_synced_at
        # last_repository_successful_sync_at
        # resync_repository
        # #repository_retry_count
        # #repository_retry_at
        # force_to_redownload_repository
        # #last_repository_sync_failure
        # last_repository_verification_failure
        # repository_verification_checksum_sha
        # repository_checksum_mismatch
        # resync_repository_was_scheduled_at
        # repository_missing_on_primary
        # repository_verification_retry_count
        # last_repository_verification_ran_at
        # repository_verification_checksum_mismatched

        # last_repository_check_failed
        # last_repository_check_at
      end
    end
  end
end
