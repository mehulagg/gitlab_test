# frozen_string_literal: true

module Geo
  class ReplicableRepositorySyncService < RepositoryBaseSyncService
    def initialize(registry_class_name, registry_id)
      @registry = registry_class_name.constantize.find(registry_id)
      @project = @registry.project
      @new_repository = false
      self.class.type = @registry.repo_type
    end

    def execute
      super unless registry.class.skippable?
    end

    private

    def sync_repository
      check_shard_health

      start_registry_sync!
      fetch_repository
      mark_sync_as_successful
    rescue Gitlab::Shell::Error, Gitlab::Git::BaseError => e
      # In some cases repository does not exist, the only way to know about this is to parse the error text.
      # If it does not exist we should consider it as successfully downloaded.
      if e.message.include? Gitlab::GitAccess::ERROR_MESSAGES[:no_repo]
        log_info("#{registry.replicable_human_name} is not found, marking it as successfully synced")
        mark_sync_as_successful(missing_on_primary: true)
      else
        fail_registry_sync!("Error syncing #{registry.replicable_human_name}", e)
      end
    rescue Gitlab::Git::Repository::NoRepository => e
      log_info("Marking the #{registry.replicable_human_name} for a forced re-download")
      fail_registry_sync!("Invalid #{registry.replicable_human_name}", e, force_to_redownload: true)
    ensure
      expire_repository_caches
    end

    def registry
      @registry
    end

    def repository
      registry.replicable
    end

    def ensure_repository
      repository.create_if_not_exists
    end

    def expire_repository_caches
      log_info("Expiring caches for #{registry.replicable_human_name}")
      repository.after_sync
    end

    def fail_registry_sync!(message, error, attrs = {})
      log_error(message, error)

      registry.fail_sync!(message, error, attrs)

      repository.clean_stale_repository_files
    end

    def start_registry_sync!
      log_info("Marking #{registry.replicable_human_name} sync as started")
      registry.start_sync!
    end

    def mark_sync_as_successful(missing_on_primary: false)
      log_info("Marking #{registry.replicable_human_name} sync as successful")

      persisted = registry.finish_sync!(missing_on_primary)

      reschedule_sync unless persisted

      log_info("Finished #{registry.replicable_human_name} sync", download_time_s: download_time_in_seconds)
    end

    def reschedule_sync
      log_info("Reschedule #{registry.replicable_human_name} sync because a concurrent update occurred")

      ::Geo::ReplicableRepositorySyncWorker.perform_async(registry.class.name, registry.id)
    end

    def download_time_in_seconds
      (Time.now.to_f - registry.last_synced_at.to_f).round(3)
    end

    def redownload?
      registry.should_be_redownloaded?
    end

    def check_shard_health
      return if Gitlab::ShardHealthCache.healthy_shard?(project.repository_storage)

      e = Struct.new(message: "Unhealthy shard \"#{project.repository_storage}\"")

      fail_registry_sync!("Error syncing #{registry.replicable_human_name}", e)
    end
  end
end
