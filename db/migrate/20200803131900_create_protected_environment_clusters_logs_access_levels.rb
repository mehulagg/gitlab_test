# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateProtectedEnvironmentClustersLogsAccessLevels < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def up
    create_table :protected_environment_clusters_logs_access_levels do |t|
      t.datetime_with_timezone "created_at", null: false
      t.datetime_with_timezone "updated_at", null: false
      t.integer "access_level", default: 40
      t.references :protected_environment, index: { name: 'idx_clusters_logs_access_levels_on_protected_environment_id' }, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, index: { name: 'index_clusters_logs_access_levels_on_user_id' }, null: true, foreign_key: { on_delete: :cascade }
      t.references :namespace, index: { name: 'index_clusters_logs_access_levels_on_namespace_id' }, null: true, foreign_key: { on_delete: :cascade }
    end
  end

  def down
    drop_table :protected_environment_clusters_logs_access_levels
  end
end
