# frozen_string_literal: true

# Abstract checker class as parent for checkers of two snippet types.
module Gitlab
  class GitAccessSnippet < GitAccess
    extend ::Gitlab::Utils::Override

    ERROR_MESSAGES = {
      snippet_not_found: 'The snippet you were looking for could not be found.',
      project_not_found: 'The project you were looking for could not be found.',
      repository_not_found: 'The snippet repository you were looking for could not be found.',
      read_snippet: 'You are not allowed to read this snippet.',
      update_snippet: 'You are not allowed to update this snippet.'
    }.freeze

    attr_reader :snippet

    def initialize(actor, snippet, protocol, **kwargs)
      @snippet = snippet

      super(actor, snippet&.project, protocol, **kwargs)

      # Only grant basic access methods
      @actor = nil if !actor.is_a?(User) && !actor.is_a?(Key)
      @auth_result_type = nil
      @authentication_abilities &= [:download_code, :push_code]
    end

    def check(cmd, changes)
      raise NotImplementedError
    end

    private

    def check_common(cmd, changes)
      unless Feature.enabled?(:version_snippets, user)
        raise NotFoundError, ERROR_MESSAGES[:project_not_found]
      end

      @logger = Checks::TimedLogger.new(timeout: INTERNAL_TIMEOUT, header: LOG_HEADER)
      @changes = changes

      check_snippet_accessibility!
      check_protocol!
      check_valid_actor!
      check_active_user!
      check_authentication_abilities!(cmd)
      check_command_disabled!(cmd)
      check_command_existence!(cmd)

      custom_action = check_custom_action(cmd)
      return custom_action if custom_action

      check_db_accessibility!(cmd)
      check_repository_existence!
    end

    def check_policy_access(cmd)
      case cmd
      when *DOWNLOAD_COMMANDS
        check_download_access!
      when *PUSH_COMMANDS
        check_push_access!
      end
    end

    override :repository
    def repository
      snippet&.repository
    end

    def check_snippet_accessibility!
      if snippet.blank?
        raise NotFoundError, ERROR_MESSAGES[:snippet_not_found]
      end
    end

    override :check_download_access!
    def check_download_access!
      passed = guest_can_download_code? || user_can_download_code?

      unless passed
        raise UnauthorizedError, ERROR_MESSAGES[:read_snippet]
      end
    end

    override :guest_can_download_code?
    def guest_can_download_code?
      Guest.can?(:read_snippet, snippet)
    end

    override :user_can_download_code?
    def user_can_download_code?
      authentication_abilities.include?(:download_code) && user_access.can_do_action?(:read_snippet)
    end

    override :check_change_access!
    def check_change_access!
      unless user_access.can_do_action?(:update_snippet)
        raise UnauthorizedError, ERROR_MESSAGES[:update_snippet]
      end
    end

    override :check_repository_existence!
    def check_repository_existence!
      unless repository.exists?
        raise NotFoundError, ERROR_MESSAGES[:repository_not_found]
      end
    end

    override :user_access
    def user_access
      @user_access ||= UserAccessSnippet.new(user, snippet: snippet)
    end
  end
end
