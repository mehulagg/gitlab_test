# frozen_string_literal: true

class AddDastScannerProfile < ActiveRecord::Migration[6.0]
  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def change
    create_table :dast_scanner_profiles do |t|
      t.text :name, null: false
      t.references :project, null: false, index: true, foreign_key: { on_delete: :cascade }, type: :integer

      t.timestamps_with_timezone null: false
    end
  end
end
