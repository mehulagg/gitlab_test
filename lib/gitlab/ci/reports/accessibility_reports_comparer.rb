# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class AccessibilityReportsComparer
        include Gitlab::Utils::StrongMemoize

        attr_reader :base_reports, :head_reports

        def initialize(base_reports, head_reports)
          @base_reports = base_reports
          @head_reports = head_reports
        end

        def added
          strong_memoize(:added) do
            @head_report.errors - @base_report.errors
          end
        end

        def fixed
          strong_memoize(:fixed) do
            @base_report.errors - @head_report.errors
          end
        end
      end
    end
  end
end
