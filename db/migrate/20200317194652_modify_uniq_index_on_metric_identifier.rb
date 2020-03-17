# frozen_string_literal: true

class ModifyUniqIndexOnMetricIdentifier < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    remove_concurrent_index :prometheus_metrics, :identifier
    add_concurrent_index    :prometheus_metrics, [:identifier, :project_id], using: :btree, unique: true
  end

  def down
    remove_concurrent_index :prometheus_metrics, [:identifier, :project_id]
    add_concurrent_index    :prometheus_metrics, :identifier, using: :btree, unique: true
  end
end
