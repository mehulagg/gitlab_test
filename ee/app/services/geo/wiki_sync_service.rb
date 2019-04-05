# frozen_string_literal: true

module Geo
  class WikiSyncService < BaseSyncService
    self.type = :wiki

    private

    def sync_repository
      fetch_repository

      mark_sync_as_successful
    rescue Gitlab::Shell::Error, Gitlab::Git::BaseError, ProjectWiki::CouldNotCreateWikiError => e
      # In some cases repository does not exist, the only way to know about this is to parse the error text.
      # If it does not exist we should consider it as successfully downloaded.
      if e.message.include? Gitlab::GitAccess::ERROR_MESSAGES[:no_repo]
        log_info('Wiki repository is not found, marking it as successfully synced')
        mark_sync_as_successful(missing_on_primary: true)
      else
        fail_registry!('Error syncing wiki repository', e)
      end
    rescue Gitlab::Git::Repository::NoRepository => e
      log_info('Setting force_to_redownload flag')
      fail_registry!('Invalid wiki', e, force_to_redownload_wiki: true)
    ensure
      expire_repository_caches
    end

    def repository
      project.wiki.repository
    end

    def ensure_repository
      project.wiki.ensure_repository
    end

    def expire_repository_caches
      log_info('Expiring caches')
      repository.after_sync
    end
  end
end
