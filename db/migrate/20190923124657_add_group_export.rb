# frozen_string_literal: true

class AddGroupExport < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_table :group_exports, id: :serial, force: :cascade do |t|
      t.references :group, null: false
      t.string :status
      t.string :last_error
      t.timestamps
    end
  end

  def down
    drop_table :group_exports
  end
end
