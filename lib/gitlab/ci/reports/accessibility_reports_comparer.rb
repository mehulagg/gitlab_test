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

        def results_comparer
          strong_memoize(:results_comparer) do
            head_reports.urls.each_with_object({}) do |(head_url, head_errors), hash|
              base_reports.urls.each do |base_url, base_errors|
                hash[base_url] = diff_result(base_errors, head_errors)
              end
            end
          end
        end

        private

        def diff_result(base_reports, head_reports)
          if base_reports.size > head_reports.size
            base_reports - head_reports
          else
            head_reports - base_reports
          end
        end
      end
    end
  end
end
