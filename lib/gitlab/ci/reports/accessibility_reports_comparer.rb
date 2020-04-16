# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class AccessibilityReportsComparer
        include Gitlab::Utils::StrongMemoize

        attr_reader :base_reports, :head_reports

        def initialize(base_reports, head_reports)
          @base_reports = base_reports || AccessibilityReports.new
          @head_reports = head_reports
        end

        def added
          strong_memoize(:added) do
            added = head_reports.errors - base_reports.errors

            added.negative? ? 0 : added
          end
        end

        def new_errors
          strong_memoize(:new_errors) do
            head_reports.urls.values.flatten - base_reports.urls.values.flatten
          end
        end
      end
    end
  end
end
