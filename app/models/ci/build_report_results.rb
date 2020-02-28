# frozen_string_literal: true

module Ci
  class BuildReportResults < ApplicationRecord
    extend Gitlab::Ci::Model

    FILE_TYPES = Ci::JobArtifact.file_types.keys

    REPORT_PARAMS = %w(
      success
      failed
      skipped
      error
      undefined
      info
      unknown
      low
      medium
      high
      critical
    )

    belongs_to :build, class_name: "Ci::Build", inverse_of: :build_report_results

    validates :file_type, :report_param, presence: true
    validates :file_type, inclusion: { in: FILE_TYPES }
    validates :report_param, inclusion: { in: REPORT_PARAMS }

    enum file_type: FILE_TYPES
    enum report_param: REPORT_PARAMS
  end
end
