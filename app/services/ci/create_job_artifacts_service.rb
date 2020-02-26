# frozen_string_literal: true

module Ci
  class CreateJobArtifactsService < ::BaseService
    ArtifactsExistError = Class.new(StandardError)
    OBJECT_STORAGE_ERRORS = [
      Errno::EIO,
      Google::Apis::ServerError,
      Signet::RemoteServerError
    ].freeze

    def execute(job, artifacts_file, metadata_file: nil)
      result = create_artifact_for(job, artifacts_file, metadata_file)
      result = parse_artifact(result[:artifact]) if result[:status] == :success
      result
    end

    private

    def create_artifact_for(job, artifacts_file, metadata_file)
      expire_in = params['expire_in'] ||
        Gitlab::CurrentSettings.current_application_settings.default_artifacts_expire_in

      job.job_artifacts.build(
        project: job.project,
        file: artifacts_file,
        file_type: params['artifact_type'],
        file_format: params['artifact_format'],
        file_sha256: artifacts_file.sha256,
        expire_in: expire_in)

      if metadata_file
        job.job_artifacts.build(
          project: job.project,
          file: metadata_file,
          file_type: :metadata,
          file_format: :gzip,
          file_sha256: metadata_file.sha256,
          expire_in: expire_in)
      end

      if job.update(artifacts_expire_in: expire_in)
        success(artifact: job.public_send("job_artifacts_#{params['artifact_type']}")) # rubocop: disable GitlabSecurity/PublicSend
      else
        error(job.errors.messages, :bad_request)
      end
    rescue ActiveRecord::RecordNotUnique => error
      return success if sha256_matches_existing_artifact?(job, params['artifact_type'], artifacts_file)

      track_exception(error, job)
      error('another artifact of the same type already exists', :bad_request)
    rescue *OBJECT_STORAGE_ERRORS => error
      track_exception(error, job)
      error(error.message, :service_unavailable)
    end

    ##
    # Synchronous parsing for time sensitive metrics/data
    def parse_artifact(artifact)
      return success(artifact: artifact) unless artifact.dotenv?

      objects = Gitlab::Ci::Parsers.fabricate!(params['artifact_type'])
                                   .parse!(artifact)

      ActiveRecord::Base.transaction(isolation: :read_committed) do
        objects.each(&:save!)
      end

      success(artifact: artifact)
    rescue Gitlab::Ci::Parsers::ParserError => error
      parse_error(error, job, artifact)
    rescue ActiveRecord::RecordNotUnique => error
      parse_error(error, job, artifact)
    end

    def sha256_matches_existing_artifact?(job, artifact_type, artifacts_file)
      existing_artifact = job.job_artifacts.find_by_file_type(artifact_type)
      return false unless existing_artifact

      existing_artifact.file_sha256 == artifacts_file.sha256
    end

    def track_exception(error, job)
      Gitlab::ErrorTracking.track_exception(error,
        job_id: job.id,
        project_id: job.project_id,
        uploading_type: params['artifact_type']
      )
    end

    def parse_error(error, job, artifact)
      artifact.destroy
      track_exception(error, job)
      error(error.message, :bad_request)
    end
  end
end
