# frozen_string_literal: true

class TestReportSummaryEntity < Grape::Entity
  expose :total_time
  expose :total_count

  expose :success_count
  expose :failed_count
  expose :skipped_count
  expose :error_count

  expose :build_report_results, using: BuildReportResultEntity, as: :test_suite_summary
end
