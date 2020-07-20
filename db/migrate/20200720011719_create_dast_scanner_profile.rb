# frozen_string_literal: true

class CreateDastScannerProfile < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:dast_scanner_profiles)
      create_table :dast_scanner_profiles do |t|
        t.text :name, null: false
        t.references :project, null: false, index: true, foreign_key: { on_delete: :cascade }, type: :integer

        t.timestamps_with_timezone null: false
      end
    end

    add_text_limit(:dast_scanner_profiles, :name, 255)
  end

  def down
    drop_table :dast_scanner_profiles
  end
end
