# frozen_string_literal: true

class AddGroupExport < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def up
    create_table :group_exports, id: :serial do |t|
      t.references :group,
                   references: :namespace,
                   column:     :group_id,
                   index:      true,
                   null:       false
      t.foreign_key :namespaces, column: :group_id, on_delete: :cascade
      t.integer :status, null: false
      t.string :status_reason, limit: 255
      t.timestamps_with_timezone
    end

    add_index :group_exports, [:group_id, :status]
  end

  def down
    drop_table :group_exports
  end
end
