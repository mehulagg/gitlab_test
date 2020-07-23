# frozen_string_literal: true

module Ci
  class PipelineArtifactService
    def execute(pipeline)
      return unless Feature.enabled?(:coverage_report_view, pipeline.project)
      return unless pipeline.has_coverage_reports?

      coverage_report = pipeline.job_artifacts.coverage_reports.first

      report = pipeline.pipeline_artifacts.create!(
        project_id: pipeline.project_id,
        file_type: 1,
        file_format: 1,
        file_store: coverage_report.file_store,
        size: coverage_report.size,
        file: CarrierWaveStringFile.new(pipeline.coverage_reports.to_json)
      )
    end
  end
end
