# frozen_string_literal: true

class LockVersionCleanupForMergeRequests < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  TMP_MERGE_REQUEST_INDEX_NAME = 'tmp_index_on_merge_requests_null_lock_version'

  disable_ddl_transaction!

  def up
    validate_not_null_constraint :merge_requests, :lock_version
    remove_concurrent_index :merge_requests, :id, where: "lock_version IS NULL", name: TMP_MERGE_REQUEST_INDEX_NAME
  end

  def down
    add_concurrent_index :merge_requests, :id, where: "lock_version IS NULL", name: TMP_MERGE_REQUEST_INDEX_NAME
  end
end
