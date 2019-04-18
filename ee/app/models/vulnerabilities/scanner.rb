# frozen_string_literal: true

module Vulnerabilities
  class Scanner < ApplicationRecord
    self.table_name = "vulnerability_scanners"

    has_many :occurrences, class_name: 'Vulnerabilities::Occurrence'

    belongs_to :project

    validates :project, presence: true
    validates :external_id, presence: true, uniqueness: { scope: :project_id }
    validates :name, presence: true

    scope :with_external_id, -> (external_ids) { where(external_id: external_ids) }

    def self.unused
      scanners = arel_table
      occurrences = Vulnerabilities::Occurrence.arel_table
      left_outer_joins = scanners
                           .join(occurrences, Arel::Nodes::OuterJoin)
                           .on(scanners[:id].eq(occurrences[:scanner_id]))
                           .join_sources
      joins(left_outer_joins)
        .where(occurrences[:scanner_id].eq(nil))
    end
  end
end
