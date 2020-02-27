# frozen_string_literal: true

class UpdateOccurrenceSeverityColumn < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!
  BATCH_SIZE = 1_000
  INTERVAL = 5.minutes

  # 23_044 records to be updated on GitLab.com,
  def up
    return unless Gitlab.ee?

    migration = Gitlab::BackgroundMigration::RemoveUndefinedOccurrenceSeverityLevel
    migration_name = migration.to_s.demodulize
    relation = migration::Occurrence.undefined_severity
    queue_background_migration_jobs_by_range_at_intervals(relation,
                                                          migration_name,
                                                          INTERVAL,
                                                          batch_size: BATCH_SIZE)
  end

  def down
    # no-op
    # This migration can not be reversed because we can not know which records had undefined severity
  end
end
