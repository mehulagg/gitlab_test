# frozen_string_literal: true

class AddPendingDeleteToCiJobArtifacts < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :ci_job_artifacts, :pending_delete, :boolean
    end
  end

  def down
    with_lock_retries do
      remove_column :ci_job_artifacts, :pending_delete
    end
  end
end
