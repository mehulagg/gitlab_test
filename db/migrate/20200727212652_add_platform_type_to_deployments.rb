# frozen_string_literal: true

class AddPlatformTypeToDeployments < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      add_column :deployments, :platform_type, :integer, limit: 2
    end

    add_concurrent_index :deployments, :platform_type
  end

  def down
    remove_concurrent_index :deployments, :platform_type

    with_lock_retries do
      remove_column :deployments, :platform_type, :integer
    end
  end
end
