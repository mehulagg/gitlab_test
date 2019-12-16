# frozen_string_literal: true

module Gitlab
  class GitAccessSnippet < GitAccess
    ERROR_MESSAGES = {
      read_only:     "You can't push code to a read-only GitLab instance.",
      write_to_snippet: "You are not allowed to write to this project's snippet."
    }.freeze

    def check(cmd, _changes)
      # unless geo?
      #   check_protocol!
      #   check_can_create_design!
      # end

      success_result(cmd)
    end

    private

    def repository
      project.wiki.repository
    end
  end
end
