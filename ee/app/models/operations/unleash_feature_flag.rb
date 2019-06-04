# frozen_string_literal: true

module Operations
  class UnleashFeatureFlag < ApplicationRecord
    self.table_name = 'operations_feature_flags'

    def readonly?
      true
    end

    def strategies
      if strategy_name
        [
          {
            name: strategy_name,
            parameters: strategy_parameters
          }
        ]
      else
        [
          {
            name: 'default',
            parameters: {}
          }
        ]
      end
    end

    def self.find_all_for(project:, environment_scope:)
      raw_sql = <<~SQL
        WITH
          feature_flag_scopes_with_precedence AS (
            SELECT *,
            CASE
              WHEN environment_scope = '*' THEN 1
              WHEN environment_scope = ? THEN 3
              WHEN ? LIKE REPLACE(REPLACE(REPLACE(environment_scope, '%', '\%'), '_', '\_'), '*', '%') THEN 2
              ELSE 0
            END AS precedence
            FROM operations_feature_flag_scopes
          ),
          max_precedence_per_feature_flag AS (
            SELECT feature_flag_id, MAX(precedence) AS max_precedence
            FROM feature_flag_scopes_with_precedence
            GROUP BY feature_flag_id
          )
        SELECT
          operations_feature_flags.name,
          operations_feature_flags.description,
          feature_flag_scopes_with_precedence.active,
          operations_feature_flag_strategies.name AS strategy_name,
          operations_feature_flag_strategies.parameters AS strategy_parameters
        FROM operations_feature_flags
        JOIN feature_flag_scopes_with_precedence ON operations_feature_flags.id = feature_flag_scopes_with_precedence.feature_flag_id
        LEFT JOIN operations_feature_flag_strategies ON feature_flag_scopes_with_precedence.id = operations_feature_flag_strategies.feature_flag_scope_id
        JOIN max_precedence_per_feature_flag
          ON max_precedence_per_feature_flag.feature_flag_id = operations_feature_flags.id
          AND max_precedence_per_feature_flag.max_precedence = feature_flag_scopes_with_precedence.precedence
        WHERE operations_feature_flags.project_id = ?
        ORDER BY operations_feature_flags.name
      SQL

      find_by_sql([raw_sql, environment_scope, environment_scope, project.id])
    end
  end
end
