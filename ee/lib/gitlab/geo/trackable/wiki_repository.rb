# frozen_string_literal: true

module Gitlab
  module Geo
    module Trackable
      class WikiRepository
        attr_accessor :registry

        def initialize(replicable_id)
          @registry = Geo::ProjectRegistry.safe_create_of_find_by(project_id: replicable_id)
        end

        def destroy!
          # TODO cannot destroy dual purpose project + wiki registry
        end

        def repository_path
          replicable.wiki.repository.disk_path
        end

        def repository_shard
          replicable.project_repository.shard.name
        end

        private

        def replicable
          @replicable ||= Project.find(registry.replicable_id)
        end

        # project_id

        # last_wiki_synced_at
        # last_wiki_successful_sync_at
        # resync_wiki
        # wiki_retry_count
        # wiki_retry_at
        # force_to_redownload_wiki
        # last_wiki_sync_failure
        # last_wiki_verification_failure
        # wiki_verification_checksum_sha
        # wiki_checksum_mismatch
        # resync_wiki_was_scheduled_at
        # wiki_missing_on_primary
        # wiki_verification_retry_count
        # last_wiki_verification_ran_at
        # wiki_verification_checksum_mismatched
      end
    end
  end
end
