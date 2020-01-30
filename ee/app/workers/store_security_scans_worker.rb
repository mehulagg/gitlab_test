# frozen_string_literal: true

class StoreSecurityScansWorker
  include ApplicationWorker
  include PipelineQueue

  feature_category :static_application_security_testing
  latency_sensitive_worker!

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(build_id)
    ::Ci::Build.find_by(id: build_id).try do |build|
      break if build.job_artifacts.security_reports.empty?

      Security::StoreScansService.new(build).execute
    end
  end
end
