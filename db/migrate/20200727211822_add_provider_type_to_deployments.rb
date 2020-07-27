# frozen_string_literal: true

class AddProviderTypeToDeployments < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      add_column :deployments, :provider_type, :integer, limit: 2
    end

    add_concurrent_index :deployments, :provider_type
  end

  def down
    remove_concurrent_index :deployments, :provider_type

    with_lock_retries do
      remove_column :deployments, :provider_type, :integer
    end
  end
end
