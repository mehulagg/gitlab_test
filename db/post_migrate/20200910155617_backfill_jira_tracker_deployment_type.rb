# frozen_string_literal: true

class BackfillJiraTrackerDeploymentType < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  MIGRATION = 'BackfillJiraTrackerDeploymentType'
  JOB_INTERVAL = 5.minutes
  JOIN = 'INNER JOIN services ON services.id = service_id'
  QUERY_CONDITIONS = "services.type = 'JiraService' AND services.active = TRUE AND deployment_type = 0"

  class JiraTrackerData < ActiveRecord::Base
    self.table_name = 'jira_tracker_data'

    include ::EachBatch
  end

  # 78_627 JiraTrackerData records, 76_313 with deployment_type == 0
  def up
    batch_size = Gitlab::Database::Migrations::BackgroundMigrationHelpers::BACKGROUND_MIGRATION_JOB_BUFFER_SIZE

    JiraTrackerData.joins(JOIN).where(QUERY_CONDITIONS)
      .each_batch(of: batch_size) do |relation, index|
      jobs  = relation.pluck(:id).map { |id| [MIGRATION, [id]] }
      delay = index * JOB_INTERVAL

      bulk_migrate_in(delay, jobs)
    end

    # JiraTrackerData.where(deployment_type: 0).each_batch(of: batch_size) do |relation, index|
    #   jobs  = relation.pluck(:id).map { |id| [MIGRATION, [id]] }
    #   delay = index * JOB_INTERVAL
    #
    #   bulk_migrate_in(delay, jobs)
    # end
  end

  def down
    # no-op
    # intentionally blank
  end
end
