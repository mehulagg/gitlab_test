# frozen_string_literal: true

class AddEnqueuedForRemovalToCiJobArtifacts < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :ci_job_artifacts, :enqueued_for_removal, :boolean
    end
  end

  def down
    with_lock_retries do
      remove_column :ci_job_artifacts, :enqueued_for_removal
    end
  end
end
