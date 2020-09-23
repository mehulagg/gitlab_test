# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateCsvExportJobs < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  def change
    create_table :csv_export_jobs do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.integer :export_type, null: false
      t.integer :status, null: false
      t.integer :file_store
      t.string :file
      t.string :jid, limit: 100, null: false, unique: true
    end
  end
end
