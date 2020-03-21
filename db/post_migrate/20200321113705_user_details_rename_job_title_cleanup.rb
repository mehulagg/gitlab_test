# frozen_string_literal: true

class UserDetailsRenameJobTitleCleanup < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    cleanup_column_rename_v2(:up, :ci_trigger_requests, :commit_id, :pipeline_id)
  end

  def down
    cleanup_column_rename_v2(:down, :ci_trigger_requests, :commit_id, :pipeline_id)
  end
end
