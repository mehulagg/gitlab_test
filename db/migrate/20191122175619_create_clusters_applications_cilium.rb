# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateClustersApplicationsCilium < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :clusters_applications_cilium do |t|
      t.references :cluster, null: false, unique: true, foreign_key: { on_delete: :cascade }, index: {unique: true}

      t.integer :status, null: false
      t.string :version, null: false
      t.string :hostname
      t.text :status_reason

      t.timestamps_with_timezone null: false
    end
  end
end
