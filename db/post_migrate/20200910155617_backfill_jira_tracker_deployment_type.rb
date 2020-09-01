# frozen_string_literal: true

class BackfillJiraTrackerDeploymentType < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  MIGRATION = 'BackfillJiraTrackerDeploymentType'

  class JiraTrackerData < ActiveRecord::Base
    self.table_name = 'jira_tracker_data'

    include ::EachBatch
  end

  # 78_627 JiraTrackerData records, 76_313 with deployment_type == 0
  def up
    batch_size = Gitlab::Database::Migrations::BackgroundMigrationHelpers::BACKGROUND_MIGRATION_JOB_BUFFER_SIZE

    JiraTrackerData.where(deployment_type: 0).each_batch(of: batch_size) do |relation|
      jobs = relation.pluck(:id).map do |id|
        [MIGRATION, [id]]
      end

      bulk_migrate_async(jobs)
    end
  end

  def down
    # no-op
    # intentionally blank
  end
end
