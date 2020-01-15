# frozen_string_literal: true

module Ci
  class UploadArtifactsService
    include Gitlab::Utils::StrongMemoize

    MissingArtifactsError = Class.new(StandardError)
    FileTooLargeError = Class.new(StandardError)

    def execute(job, params)
      @params = params

      artifacts = UploadedFile.from_params(params, :file, JobArtifactUploader.workhorse_local_upload_path)
      metadata = UploadedFile.from_params(params, :metadata, JobArtifactUploader.workhorse_local_upload_path)

      raise MissingArtifactsError, 'Artifacts file is missing' unless artifacts

      if artifacts.size > job.max_artifacts_size
        raise FileTooLargeError, 'File size exceeds max_artifacts_size limit'
      end

      job.job_artifacts.build(
        project: job.project,
        file: artifacts,
        file_type: params['artifact_type'],
        file_format: params['artifact_format'],
        file_sha256: artifacts.sha256,
        expire_in: expire_in)

      if metadata
        job.job_artifacts.build(
          project: job.project,
          file: metadata,
          file_type: :metadata,
          file_format: :gzip,
          file_sha256: metadata.sha256,
          expire_in: expire_in)
      end

      job.update(artifacts_expire_in: expire_in)
    end

    private

    def expire_in
      strong_memoize(:expire_in) do
        @params['expire_in'] ||
          Gitlab::CurrentSettings.current_application_settings.default_artifacts_expire_in
      end
    end
  end
end
