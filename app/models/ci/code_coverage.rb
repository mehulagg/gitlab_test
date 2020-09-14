# frozen_string_literal: true

module Ci
  class CodeCoverage
    def initialize(report_results:)
      @report_results = report_results
    end

    def coverage
      return 0 if coverage_count.zero?

      @report_results.sum(&:coverage) / coverage_count
    end

    def coverage_count
      @report_results.size
    end

    def last_update
      @report_results.last&.date
    end
  end
end
