# frozen_string_literal: true

module Fuzzing
  class Job < ApplicationRecord
    self.table_name = "fuzzing_jobs"

    validates :build_id, presence: true
    validates :job_type, presence: true
    validates :target, presence: true

    belongs_to :build, class_name: 'Ci::Build'
    has_one :pipeline, class_name: 'Ci::Pipeline', through: :build
    belongs_to :target, class_name: 'Fuzzing::Target'
    has_many :crashes, class_name: 'Fuzzing::Crash', inverse_of: :job

    enum job_type: {
        fuzzing: 1,
        regression: 2
    }

    enum status: {
        success: 1,
        crash: 2,
        timeout: 3
    }
  end
end
