# frozen_string_literal: true

class AddGroupFkToImportFailures < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key :import_failures, :namespaces, column: :group_id, on_delete: :cascade
    add_concurrent_index :import_failures, :group_id, where: 'group_id IS NOT NULL'
  end

  def down
    remove_foreign_key_without_error(:import_failures, column: :group_id)
    remove_concurrent_index(:import_failures, :group_id)
  end
end
