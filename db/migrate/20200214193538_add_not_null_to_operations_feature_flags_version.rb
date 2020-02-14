# frozen_string_literal: true

class AddNotNullToOperationsFeatureFlagsVersion < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    change_column_null :operations_feature_flags, :version, false, 1
  end
end
