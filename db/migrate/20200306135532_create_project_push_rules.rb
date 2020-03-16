# frozen_string_literal: true

class CreateProjectPushRules < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :project_push_rules do |t|
      t.references :project, index: true, foreign_key: { on_delete: :cascade }, null: false
      t.references :push_rule, index: true, foreign_key: { on_delete: :cascade }, null: false
    end
    add_index :project_push_rules, [:project_id, :push_rule_id], unique: true

    add_column :push_rules, :target_type, :smallint, limit: 3
  end
end
