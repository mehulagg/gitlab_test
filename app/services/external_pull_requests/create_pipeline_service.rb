# frozen_string_literal: true

# This service is responsible for creating a pipeline for a given
# ExternalPullRequest coming from other providers such as GitHub.

module ExternalPullRequests
  class CreatePipelineService < BaseService
    def execute(pull_request)
      return unless can_create_pipeline_for?(pull_request)

      create_pipeline_for(pull_request)
    end

    private

    def can_create_pipeline_for?(pull_request)
      pull_request.open? &&
        pull_request.actual_branch_head? &&
        (!pull_request.from_fork? || pull_request.project.allow_fork_pipelines_to_run_in_parent?)
    end

    def create_pipeline_for(pull_request)
      Ci::CreatePipelineService.new(project, current_user, create_params(pull_request))
        .execute(:external_pull_request_event, external_pull_request: pull_request)
    end

    def create_params(pull_request)
      {
        ref: pull_request.ref_path,
        source_sha: pull_request.source_sha,
        target_sha: pull_request.target_sha
      }
    end
  end
end
