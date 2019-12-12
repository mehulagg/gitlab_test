# frozen_string_literal: true

module Gitlab
  class GitAccessSnippet < GitAccess
    ERROR_MESSAGES = {
      read_only:     "You can't push code to a read-only GitLab instance.",
      write_to_snippet: "You are not allowed to write to this project's snippet."
    }.freeze

    def guest_can_read_snippet?
      Guest.can?(:read_project_snippet, project)
    end

    def user_can_read_snippet?
      authentication_abilities.include?(:read_project_snippet) && user_access.can_do_action?(:read_project_snippet)
    end

    def check_change_access!
      unless user_access.can_do_action?(:create_project_snippet)
        raise UnauthorizedError, ERROR_MESSAGES[:write_to_snippet]
      end

      if Gitlab::Database.read_only?
        raise UnauthorizedError, push_to_read_only_message
      end

      true
    end

    def push_to_read_only_message
      ERROR_MESSAGES[:read_only]
    end

    private

    def repository
      project.wiki.repository
    end
  end
end
