# frozen_string_literal: true

module Ci
  class PipelineProcessReportService
    def execute(pipeline)
      return unless Feature.enabled?(:coverage_report_view, pipeline.project)
      return unless pipeline.has_coverage_reports?

      report = pipeline.create_processed_report
      report_file = CarrierWaveStringFile.new(pipeline.coverage_reports.to_json)
      report.update(coverage_report: report_file)
    end
  end
end
