# frozen_string_literal: true

class AddGroupIdToImportFailures < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    add_column :import_failures, :group_id, :bigint, null: true
  end
end
