# frozen_string_literal: true

class AddIndexOnGroupExports < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index(:group_exports, [:group_id, :status])
  end

  def down
    remove_concurrent_index(:group_exports, [:group_id, :status])
  end
end
