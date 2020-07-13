# frozen_string_literal: true

module Ci
  class ProcessedReportUploader < GitlabUploader
    include ObjectStorage::Concern

    storage_options Gitlab.config.artifacts

    alias_method :upload, :model

    def filename
      "report-#{model.pipeline_id}-#{model.id}"
    end

    def store_dir
      File.join(model.model_name.plural, "pipeline-#{model.pipeline_id}")
    end
  end
end
