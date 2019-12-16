# frozen_string_literal: true

class RemoveNullConstraintOnProjectIdInImportFailures < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def up
    change_column_null :import_failures, :project_id, true
  end

  def down
    change_column_null :import_failures, :project_id, false
  end
end
