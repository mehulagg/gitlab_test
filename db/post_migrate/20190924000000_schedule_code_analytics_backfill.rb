# frozen_string_literal: true

class ScheduleCodeAnalyticsBackfill < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  BATCH_SIZE = 10_000
  INTERVAL = 3.minutes #fixme
  MIGRATION = 'Gitlab::BackgroundMigration::BackfillCodeAnalyticsData'.freeze

  disable_ddl_transaction!

  def up
    return unless Gitlab.ee?

    projects_model = Class.new(ActiveRecord::Base) do
      self.table_name = 'projects' #fixme

      include ::EachBatch
    end

    scope = projects_model.where()

    queue_background_migration_jobs_by_range_at_intervals(scope, MIGRATION, INTERVAL, batch_size: BATCH_SIZE)
  end

  def down
    # no-op
  end
end
