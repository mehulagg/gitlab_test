# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddTimestampsToDesignManagementVersions < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_timestamps_with_timezone :design_management_versions,
      columns: [:created_at],
      null: false,
      default: -> { 'CURRENT_TIMESTAMP' }
  end

  def down
    remove_column :design_management_versions, :created_at
  end
end
