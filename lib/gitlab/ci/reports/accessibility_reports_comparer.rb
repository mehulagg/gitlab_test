# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class AccessibilityReportsComparer
        include Gitlab::Utils::StrongMemoize

        STATUS_SUCCESS = 'success'
        STATUS_FAILED = 'failed'

        attr_reader :base_reports, :head_reports

        def initialize(base_reports, head_reports)
          @base_reports = base_reports || AccessibilityReports.new
          @head_reports = head_reports
        end

        def status
          head_reports.errors.positive? ? STATUS_FAILED : STATUS_SUCCESS
        end

        def existing_errors
          strong_memoize(:exiting_errors) do
            base_reports.urls.values.flatten
          end
        end

        def new_errors
          strong_memoize(:new_errors) do
            head_reports.urls.values.flatten - base_reports.urls.values.flatten
          end
        end

        def resolved_errors
          strong_memoize(:resolved_errors) do
            base_reports.urls.values.flatten & head_reports.urls.values.flatten
          end
        end

        def total_count
          head_reports.errors
        end

        def resolved_count
          resolved_errors.size
        end

        def error_count
          existing_errors.size + new_errors.size
        end
      end
    end
  end
end
