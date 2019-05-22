# frozen_string_literal: true

class AddPercentageToOperationsFeatureFlagScopes < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :operations_feature_flag_scopes, :percentage, :integer
  end
end
