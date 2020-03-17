# frozen_string_literal: true

class AddTargetTypeToPushRules < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :push_rules, :target_type, :smallint, limit: 3
  end
end
