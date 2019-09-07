# frozen_string_literal: true

module MergeRequests
  class CreatePipelineService < MergeRequests::BaseService
    def execute(merge_request)
      return unless can_create_pipeline_for?(merge_request)

      create_detached_merge_request_pipeline(merge_request)
    end

    def create_detached_merge_request_pipeline(merge_request)
      if can_use_merge_request_ref?(merge_request)
        Ci::CreatePipelineService.new(pipeline_project(merge_request), current_user,
                                      ref: merge_request.ref_path)
          .execute(:merge_request_event, merge_request: merge_request)
      else
        Ci::CreatePipelineService.new(pipeline_project(merge_request), current_user,
                                      ref: merge_request.source_branch)
          .execute(:merge_request_event, merge_request: merge_request)
      end
    end

    def can_create_pipeline_for?(merge_request)
      ##
      # UpdateMergeRequestsWorker could be retried by an exception.
      # pipelines for merge request should not be recreated in such case.
      return false if !allow_duplicate && merge_request.find_actual_head_pipeline&.triggered_by_merge_request?
      return false if merge_request.has_no_commits?

      true
    end

    def allow_duplicate
      params[:allow_duplicate]
    end

    def can_use_merge_request_ref?(merge_request)
      Feature.enabled?(:ci_use_merge_request_ref, project, default_enabled: true) &&
        (!merge_request.for_fork? || merge_request.target_project.allow_fork_pipelines_to_run_in_parent?)
    end

    def pipeline_project(merge_request)
      if merge_request.for_fork? && merge_request.target_project.allow_fork_pipelines_to_run_in_parent?
        merge_request.target_project
      else
        merge_request.source_project
      end
    end
  end
end

MergeRequests::CreatePipelineService.prepend_if_ee('EE::MergeRequests::CreatePipelineService')
