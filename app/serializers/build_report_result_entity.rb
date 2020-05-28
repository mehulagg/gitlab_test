# frozen_string_literal: true

class BuildReportResultEntity < Grape::Entity
  expose :tests_name
  expose :tests_duration
  expose :tests_success
  expose :tests_failed
  expose :tests_errored
  expose :tests_skipped
  expose :tests_total
end
