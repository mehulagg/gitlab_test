# frozen_string_literal: true

class AddCveIdRequestProjectSetting < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    add_column :projects, :cve_id_request_enabled, :boolean, default: true # rubocop:disable Migration/AddColumnsToWideTables
  end

  def down
    remove_column :projects, :cve_id_request_enabled
  end
end
