# frozen_string_literal: true

class LockVersionCleanupForEpics < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  TMP_EPIC_INDEX_NAME = 'tmp_index_on_epics_null_lock_version'

  def up
    validate_not_null_constraint :epics, :lock_version
    remove_concurrent_index :epics, :id, where: "lock_version IS NULL", name: TMP_EPIC_INDEX_NAME
  end

  def down
    add_concurrent_index :epics, :id, where: "lock_version IS NULL", name: TMP_EPIC_INDEX_NAME
  end
end
