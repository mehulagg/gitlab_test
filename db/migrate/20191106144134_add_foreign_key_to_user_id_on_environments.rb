# frozen_string_literal: true

class AddForeignKeyToUserIdOnEnvironments < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_concurrent_foreign_key :environments, :users, column: :user_id, on_delete: :nullify
    add_concurrent_index :environments, :user_id
  end

  def down
    remove_foreign_key_if_exists :environments, :user_id
    remove_concurrent_index :environments, :user_id
  end
end
