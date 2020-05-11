# frozen_string_literal: true

module Vulnerabilities
  class Stats < ApplicationRecord
    INHERITED_COLUMNS = %w(project_id).freeze

    self.table_name = 'vulnerabilities'
    self.primary_key = 'project_id'

    belongs_to :project

    default_scope { select(select_statement).group(:project_id) }

    after_initialize :readonly!

    class << self
      def select_statement
        @select_statement ||= INHERITED_COLUMNS + stats_select
      end

      # Overrides ActiveRecord::ModelSchema's method to do not inherit
      # all the attributes from vulnerabilities table.
      def ignored_columns
        Vulnerability.columns.map(&:name) - INHERITED_COLUMNS
      end

      private

      def stats_select
        Vulnerability.severities.map do |severity, enum|
          build_select_clause_for(severity, enum)
        end
      end

      def build_select_clause_for(severity, enum)
        "COUNT(*) FILTER (WHERE severity = #{enum}) as #{severity}_severity"
      end
    end
  end
end
