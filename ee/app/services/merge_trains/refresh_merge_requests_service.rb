# frozen_string_literal: true
module MergeTrains
  class RefreshMergeRequestsService < BaseService
    include ::Gitlab::ExclusiveLeaseHelpers

    ##
    # merge_request ... A merge request pointer in a merge train.
    #                   All the merge requests following the specified merge request will be refreshed.
    def execute(merge_request)
      return unless merge_request.on_train?

      Gitlab::SequentialProcess.new(key_group, 15.minutes, self.class.name, :sequential_process)
                               .execute(merge_request.id)
    end

    def sequential_process(merge_request_ids)
      merge_request = first_merge_request_from(merge_request_ids)
      unsafe_refresh(merge_request)
    end

    private

    def key_group
      "#{merge_request.target_project_id}:#{merge_request.target_branch}"
    end

    def first_merge_request_from(merge_request_ids)
      # TODO:
    end

    def unsafe_refresh(merge_request)
      following_merge_requests_from(merge_request).each do |merge_request|
        MergeTrains::RefreshMergeRequestService
          .new(merge_request.project, merge_request.merge_user)
          .execute(merge_request)
      end
    end

    def following_merge_requests_from(merge_request)
      merge_request.merge_train.all_next.to_a.unshift(merge_request)
    end
  end
end
