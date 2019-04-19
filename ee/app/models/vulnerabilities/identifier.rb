# frozen_string_literal: true

module Vulnerabilities
  class Identifier < ApplicationRecord
    include ShaAttribute

    self.table_name = "vulnerability_identifiers"

    sha_attribute :fingerprint

    has_many :occurrence_identifiers, class_name: 'Vulnerabilities::OccurrenceIdentifier'
    has_many :occurrences, through: :occurrence_identifiers, class_name: 'Vulnerabilities::Occurrence'

    has_many :primary_occurrences, class_name: 'Vulnerabilities::Occurrence', inverse_of: :primary_identifier

    belongs_to :project

    validates :project, presence: true
    validates :external_type, presence: true
    validates :external_id, presence: true
    validates :fingerprint, presence: true
    # Uniqueness validation doesn't work with binary columns, so save this useless query. It is enforce by DB constraint anyway.
    # TODO: find out why it fails
    # validates :fingerprint, presence: true, uniqueness: { scope: :project_id }
    validates :name, presence: true

    scope :with_fingerprint, -> (fingerprints) { where(fingerprint: fingerprints) }

    def self.unused
      identifiers = arel_table
      occurrence_ids = Vulnerabilities::OccurrenceIdentifier.arel_table
      occurrence_ids_joins = identifiers
                               .join(occurrence_ids, Arel::Nodes::OuterJoin)
                               .on(identifiers[:id].eq(occurrence_ids[:identifier_id]))
                               .join_sources

      occurrences = Vulnerabilities::Occurrence.arel_table
      primary_joins = identifiers
                        .join(occurrences, Arel::Nodes::OuterJoin)
                        .on(identifiers[:id].eq(occurrences[:primary_identifier_id]))
                        .join_sources

      joins(occurrence_ids_joins)
        .where(occurrence_ids[:identifier_id].eq(nil))
        .merge(joins(primary_joins)
                 .where(occurrences[:primary_identifier_id].eq(nil)))
    end
  end
end
