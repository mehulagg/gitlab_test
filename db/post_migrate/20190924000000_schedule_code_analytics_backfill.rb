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

    class Repos < ActiveRecord::Base
      include ::EachBatch

      self.table_name = 'namespace'
    end

     # scope :with_feature_available_in_plan, -> (feature) do
     #    plans = plans_with_feature(feature)
     #    matcher = Plan.where(name: plans)
     #      .joins(:hosted_subscriptions)
     #      .where("gitlab_subscriptions.namespace_id = namespaces.id")
     #      .select('1')
     #    where("EXISTS (?)", matcher)
     #  end
    # scope = repo_model.where(project: Project.where(has premium license))
    # scope = commit_model.where(project: Project.where(has premium license), committed_date: in the last 30 days)

    queue_background_migration_jobs_by_range_at_intervals(scope, MIGRATION, INTERVAL, batch_size: BATCH_SIZE)
  end

  def down
    # no-op
  end
end
