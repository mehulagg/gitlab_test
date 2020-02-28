# frozen_string_literal: true

module EE
  module VulnerabilitiesHelper
    def vulnerability_data(vulnerability)
      return unless vulnerability

      {
        id: vulnerability.id,
        state: vulnerability.state,
        created_at: vulnerability.created_at,
        report_type: vulnerability.report_type,
        project_fingerprint: vulnerability.finding.project_fingerprint,
        create_issue_url: create_vulnerability_feedback_issue_path(@vulnerability.finding.project)
      }
    end

    def vulnerability_pipeline_data(pipeline)
      return unless pipeline

      {
        id: pipeline.id,
        created_at: pipeline.created_at,
        url: pipeline_path(pipeline)
      }
    end
  end
end
