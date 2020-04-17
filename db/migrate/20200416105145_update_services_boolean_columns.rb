# frozen_string_literal: true

class UpdateServicesBooleanColumns < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    change_column_null :services, :active, true
    change_column_null :services, :commit_events, true
    change_column_null :services, :comment_on_event_enabled, true
  end

  def down
    change_column_null :services, :active, false
    change_column_null :services, :commit_events, false
    change_column_null :services, :comment_on_event_enabled, false
  end
end
