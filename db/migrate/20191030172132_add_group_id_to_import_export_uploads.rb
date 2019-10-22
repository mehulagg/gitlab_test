# frozen_string_literal: true

class AddGroupIdToImportExportUploads < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    change_table :import_export_uploads do |t|
      t.references :group, references: :namespace, column: :group_id, index: true, unique: true
      t.foreign_key :namespaces, column: :group_id, on_delete: :cascade
    end
  end
end
