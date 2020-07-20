# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddDastScannerProfile < ActiveRecord::Migration[6.0]
  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def change
    create_table :dast_scanner_profiles do |t|
      t.string :name, null: false, limit: 255
      t.references :project, null: false, index: true, foreign_key: { on_delete: :cascade }, type: :integer

      t.timestamps_with_timezone null: false
    end
  end
end
