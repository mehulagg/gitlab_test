# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class MigrateDiscussionIdOnPromotedEpics < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 100
  disable_ddl_transaction!

  def up
    Gitlab::BackgroundMigration::MigratePromotedEpicsDiscussionIds.new.perform_all_sync(batch_size: BATCH_SIZE)
  end
end
