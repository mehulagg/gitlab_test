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
            head_reports.errors - base_reports.errors
          end
        end

        def fixed
          strong_memoize(:fixed) do
            fixed = base_reports.errors - head_reports.errors

            fixed.negative? ? 0 : fixed
          end
        end
      end
    end
  end
end
