# frozen_string_literal: true

module Gitlab
  module PraefectClient
    class InfoService
      include Gitlab::EncodingHelper

      MAX_MSG_SIZE = 128.kilobytes

      def initialize(repository)
        @repository = repository
        @gitaly_repo = repository.gitaly_repository
        @storage = repository.storage
      end

      def repository_replicas
        request = Gitaly::RepositoryReplicasRequest.new(repository: @gitaly_repo)

        response = GitalyClient.call(@storage, :praefect_info_service, :repository_replicas, request, timeout: GitalyClient.fast_timeout)
      end
    end
  end
end