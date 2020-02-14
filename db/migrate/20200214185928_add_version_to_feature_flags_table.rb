# frozen_string_literal: true

class AddVersionToFeatureFlagsTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column_with_default(:operations_feature_flags, :version, :integer, default: 1, allow_null: true)
  end

  def down
    remove_column(:operations_feature_flags, :version)
  end
end
