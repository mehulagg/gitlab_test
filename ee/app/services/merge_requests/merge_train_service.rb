# frozen_string_literal: true

module MergeRequests
  class MergeTrainService < MergeRequests::BaseService
    ## Maybe we can just do `MergeRequest::BaseService#create_pipeline_for(train: true)`
    ## This definitely needs ExclusiveLease
    # def create_merge_request_pipeline_for(merge_request)
    #   # ret = ::MergeRequests::MergeToRefService.new(merge_request.project, user) # Merge to merge train sha
    #   #                                         .execute(merge_request)

    #   # Ci::CreatePipelineService.new.execute(:merge_requests,
    #   #   ref: merge_request.merge_train_ref_path,
    #   #   original_sha: merge_sha,
    #   #   source_sha: source_sha,                 # HEAD of the source branch (`refs/heads/feature`)
    #   #   target_sha: target_sha)                 # HEAD^ of the merge train branch (`refs/merge-requests/train/:target_branch`)
    # end

    # TODO: Exlusive Lease
    def merge_train_for(pipeline)
      return unless pipeline.ran_on_merge_train?

      all_merge_requests_on_train(merge_request) do |merge_request|
        next unless merge_request.actual_head_pipeline&.ran_on_merge_train?
        next unless merge_request.mergeable?

        merge_request.merge(merge_request.merge_user_id, merge_request.merge_params) # TODO: Synchronous merge
      end
    end

    def all_merge_requests_on_train(merge_request)
      MergeRequest.
        .join('LEFT JOIN ci_pipelines ON ci_pipelines.merge_request_id = merge_request.id')
        .where(project: merge_request.project)
        .where("ci_pipelines.ref = 'refs/merge-requests/trains/#{merge_request.target_branch}'")
        .order('ci_pipelines.created_at DESC')
        .all
    end
  end
end
