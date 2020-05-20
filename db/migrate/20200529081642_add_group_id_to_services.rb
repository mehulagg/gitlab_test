# frozen_string_literal: true

class AddGroupIdToServices < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  DOWNTIME = false

  def up
    add_column :services, :group_id, :integer, null: true
  end

  def down
    remove_column :services, :group_id
  end
end
