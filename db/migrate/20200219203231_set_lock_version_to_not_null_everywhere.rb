# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class SetLockVersionToNotNullEverywhere < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  TABLES = %i(epics merge_requests issues ci_stages ci_builds ci_pipelines).freeze

  def up
    TABLES.each do |table|
      change_column_null table, :lock_version, false, 0
      remove_concurrent_index table, :lock_version, where: "lock_version IS NULL"
    end
  end

  def down
    TABLES.each do |table|
      change_column_null table, :lock_version, true
      add_concurrent_index table, :lock_version, where: "lock_version IS NULL"
    end
  end
end
