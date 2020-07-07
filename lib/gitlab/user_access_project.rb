# frozen_string_literal: true

module Gitlab
  class UserAccessProject < UserAccess
    request_cache def can_create_tag?(ref)
      return false unless can_access_git?

      if protected?(ProtectedTag, project, ref)
        protected_tag_accessible_to?(ref, action: :create)
      else
        user.can?(:admin_tag, project)
      end
    end

    request_cache def can_delete_branch?(ref)
      return false unless can_access_git?

      if protected?(ProtectedBranch, project, ref)
        user.can?(:push_to_delete_protected_branch, project)
      else
        user.can?(:push_code, project)
      end
    end

    def can_update_branch?(ref)
      can_push_to_branch?(ref) || can_merge_to_branch?(ref)
    end

    request_cache def can_push_to_branch?(ref)
      return false unless can_access_git?
      return false unless project

      # Checking for an internal project to prevent an infinite loop:
      # https://gitlab.com/gitlab-org/gitlab/issues/36805
      if project.internal?
        return false unless user.can?(:push_code, project)
      else
        return false if !user.can?(:push_code, project) && !project.branch_allows_collaboration?(user, ref)
      end

      if protected?(ProtectedBranch, project, ref)
        protected_branch_accessible_to?(ref, action: :push)
      else
        true
      end
    end

    request_cache def can_merge_to_branch?(ref)
      return false unless can_access_git?

      if protected?(ProtectedBranch, project, ref)
        protected_branch_accessible_to?(ref, action: :merge)
      else
        user.can?(:push_code, project)
      end
    end

    private

    def protected_branch_accessible_to?(ref, action:)
      ProtectedBranch.protected_ref_accessible_to?(
        ref, user,
        project: project,
        action: action,
        protected_refs: project.protected_branches)
    end

    def protected_tag_accessible_to?(ref, action:)
      ProtectedTag.protected_ref_accessible_to?(
        ref, user,
        project: project,
        action: action,
        protected_refs: project.protected_tags)
    end

    request_cache def protected?(kind, project, refs)
      kind.protected?(project, refs)
    end
  end
end
