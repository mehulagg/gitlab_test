# frozen_string_literal: true

class AddRawMetaDataToSecurityScan < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    add_column :security_scans, :raw_metadata, :jsonb
  end

  def down
    remove_column :security_scans, :raw_metadata
  end
end
