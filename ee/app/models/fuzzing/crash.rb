# frozen_string_literal: true

module Fuzzing
  class Crash < ApplicationRecord
    self.table_name = "fuzzing_crashes"

    validates :exit_code, presence: true
    validates :crash_type, presence: true

    belongs_to :job, class_name: 'Fuzzing::Job'

    enum crash_type: {
        crash: 1,
        timeout: 2,
        leak: 3,
        oom: 3,
        other: 4
    }
  end
end
