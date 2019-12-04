# frozen_string_literal: true

module MergeTrains
  class CheckStatusService < BaseService
    def execute(target_project, target_branch, newrev)
      return unless target_project.merge_trains_enabled?

      last_merged_mr = MergeTrain.last_merged_mr_in_train(target_project.id, target_branch)

      # If the new revision doesn't match the merge commit of last merged merge request,
      # that means there was an unexpected commit out of merge train cycle.
      unless last_merged_mr&.merge_commit_sha == newrev
        MergeTrain.first_in_train(target_project.id, target_branch)&.merge_train&.stale!
      end
    end
  end
end
