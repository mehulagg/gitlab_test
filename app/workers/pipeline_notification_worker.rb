# frozen_string_literal: true

class PipelineNotificationWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include PipelineQueue

  urgency :high
  worker_resource_boundary :cpu

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(pipeline_id, args = {})
    case args
    when Hash
      ref_status = args[:ref_status]
      recipients = args[:recipients]
    else # TODO: backward compatible interface, can be removed in 12.10
      recipients = args
      ref_status = nil
    end

    pipeline = Ci::Pipeline.find_by(id: pipeline_id)
    return unless pipeline

    ref_status =
      if Feature.enabled?(:ci_pipeline_fixed_notifications)
        status_transition = pipeline.status_transition_on_same_context
        status_transition if status_transition == :fixed
      end

    NotificationService.new.pipeline_finished(pipeline, ref_status: ref_status, recipients: recipients)
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
