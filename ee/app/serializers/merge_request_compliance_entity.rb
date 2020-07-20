# frozen_string_literal: true

class MergeRequestComplianceEntity < Grape::Entity
  include RequestAwareEntity

  SUCCESS_APPROVAL_STATUS = :success
  WARNING_APPROVAL_STATUS = :warning
  FAILED_APPROVAL_STATUS = :failed

  expose :id
  expose :title
  expose :merged_at
  expose :milestone

  expose :path do |merge_request|
    merge_request_path(merge_request)
  end

  expose :issuable_reference do |merge_request|
    merge_request.to_reference(merge_request.project.group)
  end

  expose :author, using: API::Entities::UserBasic
  expose :approved_by_users, using: API::Entities::UserBasic

  expose :pipeline_status, if: -> (*) { can_read_pipeline? }, with: DetailedStatusEntity

  expose :approval_status

  private

  alias_method :merge_request, :object

  def can_read_pipeline?
    can?(request.current_user, :read_pipeline, merge_request.head_pipeline)
  end

  def pipeline_status
    merge_request.head_pipeline.detailed_status(request.current_user)
  end

  def approval_status
    # All these checks should be false for this to pass as a success
    # If any are true then there is a violation of the separation of duties
    checks = [
        merge_request.authors_can_approve?,
        merge_request.committers_can_approve?,
        merge_request.approvals_required < 2
    ]

    return FAILED_APPROVAL_STATUS if checks.all?
    return WARNING_APPROVAL_STATUS if checks.any?

    SUCCESS_APPROVAL_STATUS
  end
end
