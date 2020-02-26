# frozen_string_literal: true

module Ci
  class ParseDotenvArtifactService < ::BaseService
    def execute(job)
      artifact = job.job_artifacts_dotenv

      return error('Artifact Not Found') unless artifact

      variables = []

      artifact.each_blob do |blob|
        variables.concat(Gitlab::Ci::Parsers::DotenvVariable.new.parse!(blob, job))
      end

      ActiveRecord::Base.transaction { variables.each(&:save!) }

      success
    rescue => error
      parse_error(error, job)
    end

    private

    def parse_error(error, job)
      Gitlab::OptimisticLocking.retry_lock(job) do |subject|
        subject.drop(:dotenv_artifact_parse_failure)
      end

      Gitlab::ErrorTracking.track_exception(error, job_id: job.id)
      error(error.message)
    end
  end
end
