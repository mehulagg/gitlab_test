# frozen_string_literal: true

class RemoveNamespaceStorageSizeLimitFromApplicationSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      remove_column :application_settings, :namespace_storage_size_limit
    end
  end

  def down
    with_lock_retries do
      add_column :application_settings, :namespace_storage_size_limit, :bigint, default: 0
    end
  end
end
