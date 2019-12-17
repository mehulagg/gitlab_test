# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddGeoGitRepositoryRegistry < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    create_table :git_repository_registry, id: nil, force: :cascade do |t|
      t.integer :replicable_id, null: false
      t.integer :state, limit: 2
      t.integer :retry_count, default: 0
      t.string :last_sync_failure
      t.boolean :force_to_redownload
      t.boolean :missing_on_primary
      t.datetime :retry_at
      t.datetime :last_synced_at
      t.datetime :created_at, null: false
    end
  end
end
