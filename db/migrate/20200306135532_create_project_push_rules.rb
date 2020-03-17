# frozen_string_literal: true

class CreateProjectPushRules < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :project_push_rules do |t|
      t.references :project, index: { unique: true }, foreign_key: { on_delete: :cascade }, null: false
      t.references :push_rule, index: { unique: true }, foreign_key: { on_delete: :cascade }, null: false
      t.index [:project_id, :push_rule_id], unique: true, name: 'index_project_push_rules_on_project_id_and_push_rule_id'
    end
  end
end
