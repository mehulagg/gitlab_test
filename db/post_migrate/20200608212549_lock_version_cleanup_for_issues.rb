# frozen_string_literal: true

class LockVersionCleanupForIssues < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  TMP_ISSUE_INDEX_NAME = 'tmp_index_on_issues_null_lock_version'

  disable_ddl_transaction!

  def up
    validate_not_null_constraint :issues, :lock_version
    remove_concurrent_index :issues, :id, where: "lock_version IS NULL", name: TMP_ISSUE_INDEX_NAME
  end

  def down
    add_concurrent_index :issues, :id, where: "lock_version IS NULL", name: TMP_ISSUE_INDEX_NAME
  end
end
