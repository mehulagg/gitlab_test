# frozen_string_literal: true

class AddForeignKeyToProjectOnPat < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :personal_access_tokens, :project_id

    add_concurrent_foreign_key :personal_access_tokens, :projects, column: :project_id, on_delete: :cascade
  end

  def down
    remove_foreign_key_if_exists :personal_access_tokens, column: :project_id

    remove_concurrent_index :personal_access_tokens, :project_id
  end
end
