# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class PerformResetMergeStatus < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 15_000
  MIGRATION = 'ResetMergeStatus'
  DELAY_INTERVAL = 5.minutes.to_i

  disable_ddl_transaction!

  def up
    say 'Scheduling `ResetMergeStatus` jobs'

    # We currently have more than ~38_000_000 merge request records on GitLab.com.
    # This means it'll schedule ~2500 jobs (15k MRs each) with a 5 minutes gap,
    # so this should take ~211 hours for all background migrations to complete.
    # ((38_000_000 / 15_000) * 5) / 60 / 24 = ~9 days
    queue_background_migration_jobs_by_range_at_intervals(MergeRequest, MIGRATION, DELAY_INTERVAL, batch_size: BATCH_SIZE)
  end
end
