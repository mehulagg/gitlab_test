# frozen_string_literal: true

module Gitlab
  class UserAccess
    extend Gitlab::Cache::RequestCache

    request_cache_key do
      [user&.id, container&.to_global_id]
    end

    attr_reader :user
    attr_accessor :container

    def initialize(user, container: nil)
      @user = user
      @container = container
    end

    def can_do_action?(action)
      return false unless can_access_git?

      permission_cache[action] =
        permission_cache.fetch(action) do
          user.can?(action, container)
        end
    end

    def cannot_do_action?(action)
      !can_do_action?(action)
    end

    def allowed?
      return false unless can_access_git?

      if user.requires_ldap_check? && user.try_obtain_ldap_lease
        return false unless Gitlab::Auth::Ldap::Access.allowed?(user)
      end

      true
    end

    request_cache def can_create_tag?(ref)
      return false unless can_access_git?

      if protected?(ProtectedTag, container, ref)
        protected_tag_accessible_to?(ref, action: :create)
      else
        user.can?(:admin_tag, container)
      end
    end

    request_cache def can_delete_branch?(ref)
      return false unless can_access_git?

      if protected?(ProtectedBranch, container, ref)
        user.can?(:push_to_delete_protected_branch, container)
      else
        user.can?(:push_code, container)
      end
    end

    def can_update_branch?(ref)
      can_push_to_branch?(ref) || can_merge_to_branch?(ref)
    end

    request_cache def can_push_to_branch?(ref)
      return false unless can_access_git?
      return false unless container

      # Checking for an internal project or group to prevent an infinite loop:
      # https://gitlab.com/gitlab-org/gitlab/issues/36805
      if container.internal?
        return false unless user.can?(:push_code, container)
      else
        return false if !user.can?(:push_code, container) && !container.try(:branch_allows_collaboration?, user, ref)
      end

      if protected?(ProtectedBranch, container, ref)
        protected_branch_accessible_to?(ref, action: :push)
      else
        true
      end
    end

    request_cache def can_merge_to_branch?(ref)
      return false unless can_access_git?

      if protected?(ProtectedBranch, container, ref)
        protected_branch_accessible_to?(ref, action: :merge)
      else
        user.can?(:push_code, container)
      end
    end

    def can_read_project?
      return false unless can_access_git?

      user.can?(:read_project, container)
    end

    private

    def permission_cache
      @permission_cache ||= {}
    end

    request_cache def can_access_git?
      user && user.can?(:access_git)
    end

    def protected_branch_accessible_to?(ref, action:)
      return false unless container.is_a?(Project)

      ProtectedBranch.protected_ref_accessible_to?(
        ref, user,
        project: container,
        action: action,
        protected_refs: container.protected_branches)
    end

    def protected_tag_accessible_to?(ref, action:)
      return false unless container.is_a?(Project)

      ProtectedTag.protected_ref_accessible_to?(
        ref, user,
        project: container,
        action: action,
        protected_refs: container.protected_tags)
    end

    request_cache def protected?(kind, container, refs)
      kind.protected?(container, refs)
    end
  end
end
