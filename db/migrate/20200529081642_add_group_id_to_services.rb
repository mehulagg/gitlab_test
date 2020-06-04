# frozen_string_literal: true

class AddGroupIdToServices < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  DOWNTIME = false

  def up
    add_column :services, :group_id, :integer, null: true
    add_concurrent_foreign_key :services, :namespaces, column: :group_id
  end

  def down
    remove_column :services, :group_id
    remove_foreign_key_if_exists :services, column: :group_id
  end
end
