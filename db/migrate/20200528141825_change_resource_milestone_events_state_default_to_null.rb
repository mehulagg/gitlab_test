# frozen_string_literal: true

class ChangeResourceMilestoneEventsStateDefaultToNull < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    change_column_null :resource_milestone_events, :state, true
  end

  def down
    execute "UPDATE resource_milestone_events SET state = 1 WHERE state IS NULL"

    change_column_null :resource_milestone_events, :state, false
  end
end
