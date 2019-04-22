# frozen_string_literal: true

module MergeRequests
  class MergeTrainService < MergeRequests::BaseService
    FailedToCreatePipelineError = Class.new(StandardError)

    # def enqueue(merge_request)
    #   return error('Merge train is disabled') unless project.merge_trains_enabled?
    #   return error('Insufficient permission') unless merge_request.can_be_merged_by?(current_user)
    #   return error('Merge request is not mergeable') unless merge_request.mergeable?(skip_ci_check: true)

    #   train = merge_request.get_on_train!

    #   ##
    #   # If the merge request is on the first queue in the merge train,
    #   # it creates the latest merge request pipeline.
    #   if train.first_in_train?
    #     pipeline = create_pipeline_for(merge_request, current_user)
    #     merge_request.update_head_pipeline

    #     if pipeline.latest_merge_request_pipeline?
    #       raise FailedToCreatePipelineError, 'Pipeline is not the latest merge request pipeline'
    #     end
    #   end

    #   success(train: train)
    # rescue => e
    #   merge_request.get_off_train!
    #   error('Failed to get on the train')
    # end

    def process_merge_train(project, target_branch)
      return unless merge_request.merge_train && merge_request.merge_train.first?

      ##
      # Try merging regardless of its state
      # Either succeeded or failed, the merge request should be dropped from the train.
      MergeRequests::MergeService.new(project, current_user).execute(merge_request)

      if train = merge_request.get_off_train
        if next_merge_request = train.next
          create_pipeline_for(next_merge_request, current_user)
          merge_request.update_head_pipeline
        end
      else
        error('Failed to get off the train')
      end
    end

    def cancel(project, target_branch)

    end
  end
end
