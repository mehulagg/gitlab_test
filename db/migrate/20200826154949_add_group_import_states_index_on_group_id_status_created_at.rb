# frozen_string_literal: true

class AddGroupImportStatesIndexOnGroupIdStatusCreatedAt < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_group_import_states_on_group_id_status_created_at'.freeze

  disable_ddl_transaction!

  def up
    add_concurrent_index :group_import_states,
      [:group_id, :status, :created_at],
      name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :projects, INDEX_NAME
  end
end
