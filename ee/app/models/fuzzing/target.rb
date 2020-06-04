# frozen_string_literal: true

module Fuzzing
  class Target < ApplicationRecord
    self.table_name = "fuzzing_targets"

    validates :name, presence: true
    validates :project, presence: true

    belongs_to :project
    has_many :jobs, class_name: 'Fuzzing::Job'
  end
end
