# frozen_string_literal: true

module Gitlab
  class GitAccessWiki < GitAccess
    extend ::Gitlab::Utils::Override

    prepend_if_ee('EE::Gitlab::GitAccessWiki') # rubocop: disable Cop/InjectEnterpriseEditionModule

    ERROR_MESSAGES = {
      download:      'You are not allowed to download files from this wiki.',
      no_wiki_repo:  'A repository for this wiki does not exist yet.',
      read_only:     "You can't push code to a read-only GitLab instance.",
      write_to_wiki: "You are not allowed to write to this project's wiki."
    }.freeze

    override :download_ability
    def download_ability
      :download_wiki_code
    end

    override :push_ability
    def push_ability
      :create_wiki
    end

    override :check_change_access!
    def check_change_access!
      raise ForbiddenError, write_to_wiki_message unless user_can_push?
      raise ForbiddenError, push_to_read_only_message if Gitlab::Database.read_only?

      true
    end

    def push_to_read_only_message
      ERROR_MESSAGES[:read_only]
    end

    def write_to_wiki_message
      ERROR_MESSAGES[:write_to_wiki]
    end

    def no_repo_message
      ERROR_MESSAGES[:no_wiki_repo]
    end

    override :download_forbidden_message
    def download_forbidden_message
      ERROR_MESSAGES[:download]
    end

    override :repository
    def repository
      container.wiki.repository
    end
  end
end
