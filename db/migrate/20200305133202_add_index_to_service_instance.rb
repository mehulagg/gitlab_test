# frozen_string_literal: true

class AddIndexToServiceInstance < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index(:services, :instance)
  end

  def down
    remove_concurrent_index(:services, :instance)
  end
end
