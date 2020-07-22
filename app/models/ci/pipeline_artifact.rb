# frozen_string_literal: true

# This class is being used to persist generated report in a pipeline context

module Ci
  class PipelineArtifact < ApplicationRecord
    include ObjectStorage::BackgroundMove
    extend Gitlab::Ci::Model

    belongs_to :project, class_name: "Project", inverse_of: :pipeline_artifacts
    belongs_to :pipeline, class_name: "Ci::Pipeline", inverse_of: :pipeline_artifacts

    mount_uploader :file, Ci::PipelineArtifactUploader

    enum file_type: {
      coverage_report: 1,
    }

    enum file_format: {
      json: 1
    }, _suffix: true

    REPORT_TYPES = {
      coverage: :raw
    }

    def hashed_path?
      true
    end
  end
end
