# frozen_string_literal: true

class CiProjectSemaphores < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    create_table :ci_project_semaphores do |t|
      t.references :project, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.string :key, null: false
      t.integer :concurrency, null: false, default: 1
      t.index %i[project_id key], unique: true
      t.timestamps_with_timezone
    end

    create_table :ci_job_locks do |t|
      t.references :semaphore, null: false, index: false, foreign_key: { to_table: :ci_project_semaphores, on_delete: :cascade }
      t.references :job, null: false, index: false, foreign_key: { to_table: :ci_builds, on_delete: :cascade }
      t.integer :status, limit: 2, null: false
      t.integer :blocked_duration
      t.index %i[semaphore_id job_id], unique: true
      t.timestamps_with_timezone
    end
  end
end
