# frozen_string_literal: true

module Gitlab
  module GitalyClient
    class PraefectInfoService
      include Gitlab::EncodingHelper

      MAX_MSG_SIZE = 128.kilobytes

      def initialize(repository)
        @repository = repository
        @gitaly_repo = repository.gitaly_repository
        @storage = repository.storage
      end

      def replicas
        request = Gitaly::RepositoryReplicas.new(repository: @gitaly_repo)

        GitalyClient.call(@storage, :praefect_info_service, :repository_replicas, request, timeout: GitalyClient.fast_timeout)
      end
    end
  end
end