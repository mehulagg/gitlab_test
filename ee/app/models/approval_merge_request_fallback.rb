# frozen_string_literal: true

class ApprovalMergeRequestFallback
  include ::Gitlab::Utils::StrongMemoize

  attr_reader :merge_request
  delegate :approved_by_users, :project, to: :merge_request

  def initialize(merge_request)
    @merge_request = merge_request
  end

  # Implements all `WrappedApprovalRule` required methods
  def id
    'fallback-rule'
  end

  def name
    ''
  end

  def users
    User.none
  end

  def groups
    Group.none
  end

  def approvals_required
    strong_memoize(:wrapped_approval_rules) do
      if project.can_override_approvers? && merge_request.approvals_before_merge.present?
        [merge_request.approvals_before_merge.to_i, project.min_fallback_approvals].max
      else
        project.approvals_before_merge.to_i
      end
    end
  end

  def approvals_left
    @approvals_left ||= [approvals_required - approved_by_users.size, 0].max
  end

  def approvers
    []
  end

  def approved_approvers
    approved_by_users
  end

  def approved?
    approved_approvers.size >= approvals_required
  end

  def code_owner
    false
  end

  def source_rule
    nil
  end

  def regular
    false
  end

  def rule_type
    :fallback
  end

  def project
    merge_request.target_project
  end
end
