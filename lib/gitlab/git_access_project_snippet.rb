# frozen_string_literal: true

module Gitlab
  class GitAccessProjectSnippet < GitAccessSnippet
    def check(cmd, changes)
      check_common(cmd, changes)
      check_namespace!
      check_project_accessibility!
      # TODO update add_project_moved_message! to handle non-project repo
      # https://gitlab.com/gitlab-org/gitlab/issues/205646
      check_policy_access(cmd)

      success_result(cmd)
    end
  end
end
