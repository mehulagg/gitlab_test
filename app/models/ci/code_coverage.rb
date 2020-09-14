# frozen_string_literal: true

module Ci
  class CodeCoverage
    include Gitlab::Utils::StrongMemoize

    def initialize(report_results:)
      @report_results = report_results
    end

    def coverage
      strong_memoize(:coverage) do
        return 0 if coverage_count.zero?

        @report_results.sum(&:coverage) / coverage_count
      end
    end

    def coverage_count
      strong_memoize(:coverage_count) do
        @report_results.size
      end
    end

    def last_update
      strong_memoize(:last_update) do
        @report_results.last&.date
      end
    end
  end
end
