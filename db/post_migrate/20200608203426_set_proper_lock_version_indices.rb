# frozen_string_literal: true

class SetProperLockVersionIndices < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  TMP_EPIC_INDEX_NAME = 'tmp_index_on_epics_null_lock_version'
  TMP_MERGE_REQUEST_INDEX_NAME = 'tmp_index_on_merge_requests_null_lock_version'
  TMP_ISSUE_INDEX_NAME = 'tmp_index_on_issues_null_lock_version'

  def up
    remove_concurrent_index :epics, :lock_version, where: "lock_version IS NULL"
    remove_concurrent_index :merge_requests, :lock_version, where: "lock_version IS NULL"
    remove_concurrent_index :issues, :lock_version, where: "lock_version IS NULL"

    add_concurrent_index :epics, :id, where: "lock_version IS NULL", name: TMP_EPIC_INDEX_NAME
    add_concurrent_index :merge_requests, :id, where: "lock_version IS NULL", name: TMP_MERGE_REQUEST_INDEX_NAME
    add_concurrent_index :issues, :id, where: "lock_version IS NULL", name: TMP_ISSUE_INDEX_NAME
  end

  def down
    add_concurrent_index :epics, :lock_version, where: "lock_version IS NULL"
    add_concurrent_index :merge_requests, :lock_version, where: "lock_version IS NULL"
    add_concurrent_index :issues, :lock_version, where: "lock_version IS NULL"

    remove_concurrent_index :epics, :id, where: "lock_version IS NULL", name: TMP_EPIC_INDEX_NAME
    remove_concurrent_index :merge_requests, :id, where: "lock_version IS NULL", name: TMP_MERGE_REQUEST_INDEX_NAME
    remove_concurrent_index :issues, :id, where: "lock_version IS NULL", name: TMP_ISSUE_INDEX_NAME
  end
end
