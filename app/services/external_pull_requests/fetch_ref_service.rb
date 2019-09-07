# frozen_string_literal: true

# This service is responsible for creating a pipeline for a given
# ExternalPullRequest coming from other providers such as GitHub.

module ExternalPullRequests
  class FetchRefService < BaseService
    def execute(pull_request)
      # TODO: Fetching refs to refs/pull would be better
      refmap = ["+refs/pull/#{pull_request.pull_request_iid}/head:refs/merge-requests/#{pull_request.pull_request_iid}/head"]

      project.repository.fetch_as_mirror(project.import_url, refmap: refmap, forced: true, remote_name: 'github')
    end
  end
end
