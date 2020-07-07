# frozen_string_literal: true

module Gitlab
  class UserAccessSnippet < UserAccess
    extend ::Gitlab::Cache::RequestCache
    # TODO: apply override check https://gitlab.com/gitlab-org/gitlab/issues/205677

    request_cache_key do
      [user&.id, snippet&.id]
    end

    attr_reader :snippet

    def initialize(user, snippet: nil)
      super(user, project: snippet&.project)
      @snippet = snippet
    end

    def allowed?
      return true if snippet_migration?

      super
    end

    def can_do_action?(action)
      return true if snippet_migration?

      super
    end

    def can_push_to_branch?(ref)
      return true if snippet_migration?
      return false unless snippet

      can_do_action?(:update_snippet)
    end

    protected

    def policy_subject
      snippet
    end

    private

    def snippet_migration?
      user&.migration_bot? && snippet
    end
  end
end
