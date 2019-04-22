# frozen_string_literal: true

module MergeRequests
  class MergeTrainService < MergeRequests::BaseService
    def enqueue(merge_request)
      return error('Merge train is disabled') unless project.merge_trains_enabled?
      return error('Insufficient permission') unless merge_request.can_be_merged_by?(current_user)
      return error('Merge request is not mergeable') unless merge_request.mergeable?(skip_ci_check: true)

      if train = merge_request.get_on_train
        create_pipeline_for(merge_request, current_user) if train.first?
      else
        error('Failed to get on the train')
      end
    end

    def finalize(merge_request)
      return unless merge_request.merge_train && merge_request.merge_train.first?

      ##
      # Try merging regardless of its state
      # Either succeeded or failed, the merge request should be dropped from the train.
      MergeRequests::MergeService.new(project, current_user).merge(merge_request)

      if train = merge_request.get_off_train
        next_merge_request = train.next
        create_pipeline_for(next_merge_request, current_user) if next_merge_request
      else
        error('Failed to get off the train')
      end
    end
  end
end
