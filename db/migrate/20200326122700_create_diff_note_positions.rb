# frozen_string_literal: true

class CreateDiffNotePositions < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :diff_note_positions do |t|
      t.references :note, foreign_key: { on_delete: :cascade }, null: false
      t.integer :old_line
      t.integer :new_line
      t.integer :position_type, limit: 2, null: false
      t.integer :type, limit: 2, null: false
      t.string :line_code, limit: 255, null: false
      t.binary :base_sha, null: false
      t.binary :start_sha, null: false
      t.binary :head_sha, null: false
      t.text :old_path, null: false
      t.text :new_path, null: false
    end
  end
end
