# frozen_string_literal: true

module Ci
  class PipelineArtifactService
    def execute(pipeline)
      return unless Feature.enabled?(:coverage_report_view, pipeline.project)
      return unless pipeline.has_coverage_reports?

      report = pipeline.pipeline_artifacts.create!(
        project_id: pipeline.project_id,
        file_type: 1,
        size: pipeline.job_artifacts.coverage_reports.first.size,
        file_format: 1,
        file: CarrierWaveStringFile.new(pipeline.coverage_reports.to_json)
      )
    end
  end
end
