# frozen_string_literal: true

module Ci
  class PipelineReportProcessor < ApplicationRecord
    include ObjectStorage::BackgroundMove
    extend Gitlab::Ci::Model

    belongs_to :pipeline, inverse_of: :processed_report

    mount_uploader :coverage_report, Ci::ProcessedReportUploader
  end
end
