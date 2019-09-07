# frozen_string_literal: true

class SyncGithubRefWorker
  include ApplicationWorker

  def perform(external_pull_request_id)
    ExternalPullRequest.find_by_id(external_pull_request_id).try do |pull_request|
      ExternalPullRequests::FetchRefService
        .new(pull_request.project, pull_request.author).execute(pull_request)

      ExternalPullRequests::CreatePipelineService
        .new(pull_request.project, pull_request.author).execute(pull_request)
    end
  end
end
