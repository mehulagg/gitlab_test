# frozen_string_literal: true

module AutoMerge
  class AddToMergeTrainWhenPipelineSucceedsService < AutoMerge::BaseService
    def execute(merge_request)
      super do
        if merge_request.saved_change_to_auto_merge_enabled?
          SystemNoteService.add_to_merge_train_when_pipeline_succeeds(merge_request, project, current_user, merge_request.diff_head_commit)
        end
      end
    end

    def process(merge_request)
      return unless merge_request.actual_head_pipeline&.success?

      merge_train_service = AutoMerge::MergeTrainService.new(project, merge_request.merge_user)
      return cancel(merge_request) unless merge_train_service.available_for?(merge_request)

      # Disable auto_merge_enabled flag in the merge request instance for swapping auto merge strategy
      merge_request.auto_merge_enabled = false
      merge_train_service.execute(merge_request)
    end

    def cancel(merge_request)
      super(merge_request) do
        SystemNoteService.cancel_add_to_merge_train_when_pipeline_succeeds(merge_request, project, current_user)
      end
    end

    def available_for?(merge_request)
      return false unless merge_request.project.merge_trains_enabled?
      return false if merge_request.for_fork?
      return false unless merge_request.actual_head_pipeline&.active?
      return false unless merge_request.mergeable_state?(skip_ci_check: true)

      true
    end
  end
end
