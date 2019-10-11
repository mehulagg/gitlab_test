# frozen_string_literal: true

class AddExportFileColumnToGroupExportPart < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    add_column :group_export_parts, :export_file, :text
  end
end
