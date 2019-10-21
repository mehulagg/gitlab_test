class AddTypeToResetChecksumEvent < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  def change
    add_column :geo_reset_checksum_events, :resource_type, :integer
  end
end
