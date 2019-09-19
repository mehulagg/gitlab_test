# frozen_string_literal: true

class AddIndexOnGroupExportParts < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index(:group_export_parts, [:group_export_id, :status])
  end

  def down
    remove_concurrent_index(:group_export_parts, [:group_export_id, :status])
  end
end
