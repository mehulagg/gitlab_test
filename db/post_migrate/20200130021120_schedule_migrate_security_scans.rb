# frozen_string_literal: true

class ScheduleMigrateSecurityScans < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INTERVAL = 5.minutes.to_i
  BATCH_SIZE = 1000
  MIGRATION = 'MigrateSecurityScans'.freeze

  disable_ddl_transaction!

  class JobArtifact < ActiveRecord::Base
    include ::EachBatch

    self.table_name = 'ci_job_artifacts'

    SAST = 5
    DEPENDENCY_SCANNING = 6
    CONTAINER_SCANNING = 7
    DAST = 8

    scope :security_reports, -> { where(file_type: [SAST, DEPENDENCY_SCANNING, CONTAINER_SCANNING, DAST]) }
  end

  def up
    JobArtifact.security_reports.each_batch(of: BATCH_SIZE) do |batch, index|
      artifact_ids = batch.pluck(:id)
      delay = INTERVAL * index
      BackgroundMigrationWorker.perform_in(delay, MIGRATION, artifact_ids)
    end
  end

  def down
    # intentionally blank
  end
end
