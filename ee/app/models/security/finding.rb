# frozen_string_literal: true

# This model represents the vulnerability findings
# discovered for all pipelines to use in pipeline
# security tab.
#
# Unlike `Vulnerabilities::Finding` model, this one
# only stores some important meta information to
# calculate which report artifact to download and parse.
module Security
  class Finding < ApplicationRecord
    self.table_name = 'security_findings'

    belongs_to :scan, inverse_of: :findings, optional: false
    belongs_to :scanner, class_name: 'Vulnerabilities::Scanner', inverse_of: :security_findings, optional: false

    has_one :build, through: :scan

    # TODO: These are duplicated between this model and Vulnerabilities::Finding,
    # we should create a shared module to encapculate this in one place.
    enum confidence: Vulnerabilities::Finding::CONFIDENCE_LEVELS, _prefix: :confidence
    enum severity: Vulnerabilities::Finding::SEVERITY_LEVELS, _prefix: :severity

    validates :project_fingerprint, presence: true, length: { maximum: 40 }

    scope :by_severity_levels, -> (severity_levels) { where(severity: severity_levels) }
    scope :by_confidence_levels, -> (confidence_levels) { where(confidence: confidence_levels) }
    scope :by_report_types, -> (report_types) { joins(:scan).merge(Scan.by_scan_types(report_types)) }
    scope :undismissed, -> { where('NOT EXISTS (?)', has_dismissal_feedback) }
    scope :has_dismissal_feedback, -> do
      Scan.select(1)
          .has_dismissal_feedback
          .where('vulnerability_feedback.project_fingerprint = security_findings.project_fingerprint')
    end
    scope :ordered, -> { order(severity: :desc, confidence: :desc) }
  end
end
