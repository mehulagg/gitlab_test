# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class MigrateDiscussionIdOnPromotedEpics < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 500
  DELAY_INTERVAL = 2.minutes
  MIGRATION = 'FixPromotedEpicsDiscussionIds'

  disable_ddl_transaction!

  class Epic < ActiveRecord::Base
    include EachBatch

    self.table_name = 'epics'
  end

  def up
    queue_background_migration_jobs_by_range_at_intervals(Epic, MIGRATION, DELAY_INTERVAL)
  end

  def down
    # no-op
  end
end
