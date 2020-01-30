# frozen_string_literal: true

module Geo
  # This class is responsible for:
  #   * Handling file requests from the secondary over the API
  #   * Returning the necessary response data to send the file back
  class FileUploadService < BaseFileService
    attr_reader :auth_header
    include ::Gitlab::Utils::StrongMemoize

    def initialize(params)
      super(params[:type], params[:id])
    end

    # Returns { code: :ok, file: CarrierWave File object } upon success
    def execute
      retriever.execute
    end

    def retriever
      retriever_klass.new(object_db_id, object_type)
    end

    private

    def decoded_authorization
      strong_memoize(:decoded_authorization) do
        ::Gitlab::Geo::JwtRequestDecoder.new(auth_header).decode
      end
    end

    def retriever_klass
      return Gitlab::Geo::Replication::FileRetriever if user_upload?
      return Gitlab::Geo::Replication::JobArtifactRetriever if job_artifact?
      return Gitlab::Geo::Replication::LfsRetriever if lfs?

      fail_unimplemented_klass!(type: 'Retriever')
    end
  end
end
