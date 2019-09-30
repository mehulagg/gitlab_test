# frozen_string_literal: true

class CreateTableOperationsFeatureFlagsIssues < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :operations_feature_flags_issues do |t|
      t.references :feature_flag, index: false, foreign_key: { on_delete: :cascade, to_table: :operations_feature_flags }, null: false
      t.references :issue, index: false, foreign_key: { on_delete: :cascade }, null: false
      t.timestamps_with_timezone null: false
    end

    add_index :operations_feature_flags_issues,
      [:feature_flag_id, :issue_id],
      name: 'index_ops_feature_flags_issues_on_feature_flag_id_and_issue_id',
      unique: true
  end
end
