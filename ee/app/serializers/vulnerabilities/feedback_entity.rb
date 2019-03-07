# frozen_string_literal: true

class Vulnerabilities::FeedbackEntity < Grape::Entity
  include RequestAwareEntity

  expose :id
  expose :project_id
  expose :author, using: UserEntity
  expose :pipeline, if: -> (feedback, _) { feedback.pipeline.present? } do
    expose :id do |feedback|
      feedback.pipeline.id
    end

    expose :path do |feedback|
      project_pipeline_path(feedback.pipeline.project, feedback.pipeline)
    end
  end

  expose :issue_iid, if: -> (feedback, _) { feedback.issue? } do |feedback|
    feedback.issue.iid
  end

  expose :issue_url, if: -> (feedback, _) { feedback.issue? } do |feedback|
    project_issue_url(feedback.project, feedback.issue)
  end

  expose :merge_request_iid, if: -> (feedback, _) { feedback.merge_request? } do |feedback|
    feedback.merge_request.iid
  end

  expose :merge_request_path, if: -> (feedback, _) { feedback.merge_request? } do |feedback|
    project_merge_request_path(feedback.project, feedback.merge_request)
  end

  expose :destroy_vulnerability_feedback_dismissal_path, if: ->(_, _) { feedback.dismissal? && can_destroy_dismissal_feedback? }

  expose :category
  expose :feedback_type
  expose :branch do |feedback|
    feedback&.pipeline&.ref
  end
  expose :project_fingerprint

  alias_method :feedback, :object

  private

  def destroy_vulnerability_feedback_dismissal_path
    project_vulnerability_feedback_path(feedback.project, feedback)
  end

  def can_destroy_dismissal_feedback?
    can?(request.current_user, :destroy_vulnerability_feedback_dismissal, feedback.project)
  end
end
