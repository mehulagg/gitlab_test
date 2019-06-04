# frozen_string_literal: true

class CreateOperationsFeatureFlagStrategies < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :operations_feature_flag_strategies do |t|
      t.references :feature_flag_scope,
        foreign_key: { to_table: :operations_feature_flag_scopes, on_delete: :cascade },
        index: { name: :index_ops_feature_flag_strategies_on_feature_flag_scope_id },
        null: false
      t.string :name, null: false
      t.jsonb :parameters, null: false
    end
  end
end
