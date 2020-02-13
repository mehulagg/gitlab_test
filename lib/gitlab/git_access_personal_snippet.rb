# frozen_string_literal: true

module Gitlab
  class GitAccessPersonalSnippet < GitAccessSnippet
    extend ::Gitlab::Utils::Override

    def check(cmd, changes)
      check_common(cmd, changes)
      check_policy_access(cmd)

      success_result(cmd)
    end

    private

    override :check_push_access!
    def check_push_access!
      if user
        # User access is verified in check_change_access!
      else
        raise UnauthorizedError, ERROR_MESSAGES[:upload]
      end

      check_change_access!
    end
  end
end
