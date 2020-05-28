# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class TestReportSummary
        attr_reader :build_report_results

        def initialize(build_report_results)
          @build_report_results = build_report_results
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def total_time
          build_report_results.sum(&:tests_duration)
        end

        def success_count
          build_report_results.sum(&:tests_success)
        end

        def failed_count
          build_report_results.sum(&:tests_failed)
        end

        def skipped_count
          build_report_results.sum(&:tests_skipped)
        end

        def error_count
          build_report_results.sum(&:tests_errored)
        end

        def total_count
          [success_count, failed_count, skipped_count, error_count].sum
        end
        # rubocop: disable CodeReuse/ActiveRecord
      end
    end
  end
end
