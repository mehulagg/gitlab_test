# frozen_string_literal: true

class CreateIndexOnAutoStopIn < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :environments, :auto_stop_at, where: 'auto_stop_at IS NOT NULL'
  end

  def down
    remove_concurrent_index :environments, :auto_stop_at
  end
end
