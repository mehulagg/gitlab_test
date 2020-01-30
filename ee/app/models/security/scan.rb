# frozen_string_literal: true

module Security
  class Scan < ApplicationRecord
    self.table_name = 'security_scans'

    belongs_to :build, class_name: 'Ci::Build'
    belongs_to :pipeline, class_name: 'Ci::Pipeline'

    enum scan_type: {
      sast: 1,
      dependency_scanning: 2,
      container_scanning: 3,
      dast: 4
    }
  end
end
