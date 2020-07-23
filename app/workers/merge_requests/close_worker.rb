# frozen_string_literal: true

module MergeRequests
  class CloseWorker
    include ApplicationWorker

    feature_category :source_code_management
    urgency :high
    worker_resource_boundary :cpu
    weight 3
    loggable_arguments 0, 1, 2
    idempotent!

    LOG_TIME_THRESHOLD = 90 # seconds

    # rubocop: disable CodeReuse/ActiveRecord
    def perform(project_id, user_id, merge_request_id)
      project = Project.find_by!(id: project_id)
      user = User.find_by!(id: user_id)
      merge_request = MergeRequest.find_by!(id: merge_request_id)

      MergeRequests::CloseService.new(project, user).execute(merge_request)
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
