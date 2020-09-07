# frozen_string_literal: true

module Security
  class Scan < ApplicationRecord
    self.table_name = 'security_scans'

    validates :build_id, presence: true
    validates :scan_type, presence: true

    belongs_to :build, class_name: 'Ci::Build'

    has_one :pipeline, class_name: 'Ci::Pipeline', through: :build

    has_many :findings, inverse_of: :scan

    enum scan_type: {
      sast: 1,
      dependency_scanning: 2,
      container_scanning: 3,
      dast: 4,
      secret_detection: 5,
      coverage_fuzzing: 6
    }

    scope :by_scan_types, -> (scan_types) { where(scan_type: scan_types) }
    scope :has_dismissal_feedback, -> do
      joins(build: { project: :vulnerability_feedback })
        .where('vulnerability_feedback.category = (security_scans.scan_type - 1)')
        .merge(Vulnerabilities::Feedback.for_dismissal)
    end

    delegate :project, to: :build
  end
end
