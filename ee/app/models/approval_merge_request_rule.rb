# frozen_string_literal: true

class ApprovalMergeRequestRule < ApplicationRecord
  include Gitlab::Utils::StrongMemoize
  include ApprovalRuleLike
  include UsageStatistics

  scope :not_matching_pattern, -> (pattern) { code_owner.where.not(name: pattern) }
  scope :matching_pattern, -> (pattern) { code_owner.where(name: pattern) }

  scope :from_project_rule, -> (project_rule) do
    joins(:approval_merge_request_rule_source)
      .where(
        approval_merge_request_rule_sources: { approval_project_rule_id: project_rule.id }
      )
  end
  scope :for_unmerged_merge_requests, -> (merge_requests = nil) do
    query = joins(:merge_request).where.not(merge_requests: { state_id: MergeRequest.available_states[:merged] })

    if merge_requests
      query.where(merge_request_id: merge_requests)
    else
      query
    end
  end
  scope :code_owner_approval_optional, -> { code_owner.where(approvals_required: 0) }
  scope :code_owner_approval_required, -> { code_owner.where('approvals_required > 0') }
  scope :with_added_approval_rules, -> { left_outer_joins(:approval_merge_request_rule_source).where(approval_merge_request_rule_sources: { approval_merge_request_rule_id: nil }) }

  validates :name, uniqueness: { scope: [:merge_request_id, :rule_type, :section] }
  validates :rule_type, uniqueness: { scope: :merge_request_id, message: proc { _('any-approver for the merge request already exists') } }, if: :any_approver?
  validates :report_type, presence: true, if: :report_approver?

  belongs_to :merge_request, inverse_of: :approval_rules

  # approved_approvers is only populated after MR is merged
  has_and_belongs_to_many :approved_approvers, class_name: 'User', join_table: :approval_merge_request_rules_approved_approvers
  has_one :approval_merge_request_rule_source
  has_one :approval_project_rule, through: :approval_merge_request_rule_source
  alias_method :source_rule, :approval_project_rule

  validate :validate_approval_project_rule

  enum rule_type: {
    regular: 1,
    code_owner: 2,
    report_approver: 3,
    any_approver: 4
  }

  alias_method :regular, :regular?
  alias_method :code_owner, :code_owner?

  enum report_type: {
    security: 1,
    license_scanning: 2
  }

  scope :security_report, -> { report_approver.where(report_type: :security) }
  scope :license_compliance, -> { report_approver.where(report_type: :license_scanning) }
  scope :with_head_pipeline, -> { includes(merge_request: [:head_pipeline]) }
  scope :open_merge_requests, -> { merge(MergeRequest.opened) }
  scope :for_checks_that_can_be_refreshed, -> { license_compliance.open_merge_requests.with_head_pipeline }

  def self.find_or_create_code_owner_rule(merge_request, entry)
    merge_request.approval_rules.code_owner.where(name: entry.pattern).where(section: entry.section).first_or_create do |rule|
      rule.rule_type = :code_owner
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def audit_add(_model)
    # no-op
    # only audit on project rule
  end

  def audit_remove(_model)
    # no-op
    # only audit on project rule
  end

  def project
    merge_request.target_project
  end

  def approval_project_rule_id=(approval_project_rule_id)
    self.approval_merge_request_rule_source ||= build_approval_merge_request_rule_source
    self.approval_merge_request_rule_source.approval_project_rule_id = approval_project_rule_id
  end

  # Users who are eligible to approve, including specified group members.
  # Excludes the author if 'self-approval' isn't explicitly
  # enabled on project settings.
  # @return [Array<User>]
  def approvers
    strong_memoize(:approvers) do
      scope_or_array = super

      next scope_or_array unless merge_request.author
      next scope_or_array if project.merge_requests_author_approval?

      if scope_or_array.respond_to?(:where)
        scope_or_array.where.not(id: merge_request.author)
      else
        scope_or_array - [merge_request.author]
      end
    end
  end

  def sync_approved_approvers
    # Before being merged, approved_approvers are dynamically calculated in ApprovalWrappedRule instead of being persisted.
    return unless merge_request.merged?

    approvers = ApprovalWrappedRule.wrap(merge_request, self).approved_approvers

    self.approved_approver_ids = approvers.map(&:id)
  end

  def refresh_required_approvals!(project_approval_rule)
    return unless report_approver?

    refresh_license_scanning_approvals(project_approval_rule) if license_scanning?
  end

  private

  def validate_approval_project_rule
    return if approval_project_rule.blank?
    return if merge_request.project == approval_project_rule.project

    errors.add(:approval_project_rule, 'must be for the same project')
  end

  def refresh_license_scanning_approvals(project_approval_rule)
    license_report = merge_request.head_pipeline&.license_scanning_report
    return if license_report.blank?

    if license_report.violates?(project.software_license_policies)
      update!(approvals_required: project_approval_rule.approvals_required)
    else
      update!(approvals_required: 0)
    end
  end
end
