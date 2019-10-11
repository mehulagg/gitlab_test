# frozen_string_literal: true

class AddExportFileColumnToGroupExport < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    add_column :group_exports, :export_file, :text
  end
end
