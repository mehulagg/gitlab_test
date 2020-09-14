# frozen_string_literal: true

module Ci
  class CodeCoverage
    include Gitlab::Utils::StrongMemoize

    def initialize(report_results:)
      @report_results = report_results
    end

    def average
      strong_memoize(:average) do
        return 0 if count.zero?

        @report_results.sum(&:coverage) / count
      end
    end

    def count
      strong_memoize(:count) do
        @report_results.size
      end
    end

    def last_update_at
      strong_memoize(:last_update_at) do
        @report_results.last&.date
      end
    end
  end
end
