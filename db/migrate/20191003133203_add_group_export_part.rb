# frozen_string_literal: true

class AddGroupExportPart < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def up
    create_table :group_export_parts, id: :serial do |t|
      t.references :group_export,
                   null:        false,
                   index:       true,
                   foreign_key: { on_delete: :cascade }
      t.integer :status, null: false
      t.string :status_reason, limit: 255
      t.string :jid, limit: 255
      t.string :name, null: false, limit: 255
      t.jsonb :params, null: false
      t.timestamps_with_timezone
    end

    add_index :group_export_parts, [:group_export_id, :status]
  end

  def down
    drop_table :group_export_parts
  end
end
