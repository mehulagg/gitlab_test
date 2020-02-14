# frozen_string_literal: true

module Gitlab
  class GitAccessPersonalSnippet < GitAccessSnippet
    extend ::Gitlab::Utils::Override

    def check(cmd, changes)
      check_common(cmd, changes)
      check_policy_access(cmd)

      success_result(cmd)
    end
  end
end
