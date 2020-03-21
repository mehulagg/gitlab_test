# frozen_string_literal: true

class UserDetailsRenameJobTitle < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    # We use ALTER TABLE, instead of rename_table
    # as we do not want to touch indexes
    #
    # Since this is run in transaction it should be safe to do "atomically"
    column_rename_v2(:up, :ci_trigger_requests, :commit_id, :pipeline_id)
  end

  def down
    column_rename_v2(:down, :ci_trigger_requests, :commit_id, :pipeline_id)
  end
end
