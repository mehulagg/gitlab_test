# frozen_string_literal: true

class AddStorageVersionToNamespace < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false
  disable_ddl_transaction!

  def up
    unless column_exists?(:namespaces, :storage_version)
      add_column_with_default(
        :namespaces,
        :storage_version,
        :integer,
        default: 2,
        allow_null: false
      )
    end
  end

  def down
    if column_exists?(:namespaces, :storage_version)
      remove_column(:namespaces, :storage_version)
    end
  end
end
