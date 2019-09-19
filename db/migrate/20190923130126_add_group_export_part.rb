# frozen_string_literal: true

class AddGroupExportPart < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_table :group_export_parts, id: :serial do |t|
      t.references :group_export, null: false
      t.string :status
      t.string :jid
      t.string :last_error
      t.string :name, null: false
      t.jsonb :params, null: false
      t.timestamps
    end
  end

  def down
    drop_table :group_export_parts
  end
end
