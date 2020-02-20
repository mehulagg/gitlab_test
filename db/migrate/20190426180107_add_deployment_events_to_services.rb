# frozen_string_literal: true

class AddDeploymentEventsToServices < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  # rubocop:disable Migration/UpdateLargeTable
  # rubocop:disable Migration/AddColumnWithDefault
  def up
    add_column_with_default(:services, :deployment_events, :boolean, default: false, allow_null: false)
  end
  # rubocop:enable Migration/UpdateLargeTable
  # rubocop:enable Migration/AddColumnWithDefault

  def down
    remove_column(:services, :deployment_events)
  end
end
