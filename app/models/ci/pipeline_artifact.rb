# frozen_string_literal: true

# This class is being used to persist generated report  common logic for creating new controllers in a pipeline context

module Ci
  class PipelineArtifact < ApplicationRecord
    include ObjectStorage::BackgroundMove
    extend Gitlab::Ci::Model

    NotSupportedAdapterError = Class.new(StandardError)

    belongs_to :project, class_name: "Project", inverse_of: :pipeline_artifacts
    belongs_to :pipeline, class_name: "Ci::Pipeline", inverse_of: :pipeline_artifacts

    mount_uploader :file, Ci::PipelineArtifactUploader

    enum file_type: {
      coverate_report: 1,
    }

    enum file_format: {
      raw: 1,
      zip: 2,
      gzip: 3
    }, _suffix: true

    REPORT_TYPES = {
      coverage: :raw
    }
  end
end
