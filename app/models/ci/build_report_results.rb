# frozen_string_literal: true

module Ci
  class BuildReportResults < ApplicationRecord
    extend Gitlab::Ci::Model

    REPORT_TYPES = {
      junit: 0,
      codequality: 1,
      sast: 2,
      dast: 3,
      dependency_scanning: 4,
      container_scanning: 5
    }

    REPORT_PARAMS = {
      success: 0,
      failed: 1,
      skipped: 2,
      error: 3,
      undefined: 4,
      info: 5,
      unknown: 6,
      low: 7,
      medium: 8,
      high: 9,
      critical: 10
    }

    belongs_to :build, class_name: "Ci::Build", inverse_of: :build_report_results

    validates :report_type, :report_param, presence: true

    enum report_type: REPORT_TYPES
    enum report_param: REPORT_PARAMS
  end
end
