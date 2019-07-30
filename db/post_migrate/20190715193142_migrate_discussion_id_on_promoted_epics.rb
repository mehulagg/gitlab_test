# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class MigrateDiscussionIdOnPromotedEpics < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 1000
  DELAY_INTERVAL = 2.minutes
  MIGRATION = 'FixPromotedEpicsDiscussionIds'

  disable_ddl_transaction!

  class Note < ActiveRecord::Base
    include EachBatch
    self.table_name = 'notes'

    def self.fetch_discussion_ids_query
      promoted_epics_query = Note
                               .where(system: true)
                               .where(noteable_type: 'Epic')
                               .where("note LIKE 'promoted from%'")
                               .select("DISTINCT noteable_id")
      Note.where(noteable_type: 'Epic')
        .where(noteable_id: promoted_epics_query)
        .select("DISTINCT discussion_id").order(:discussion_id)
    end
  end

  def up
    # add_concurrent_index(:system_note_metadata, :action)

    all_discussion_ids = Note.fetch_discussion_ids_query.collect(&:discussion_id)
    index = 0
    all_discussion_ids.in_groups_of(BATCH_SIZE) do |ids|
      index += 1
      delay = DELAY_INTERVAL * index
      BackgroundMigrationWorker.perform_in(delay, MIGRATION, [ids.compact])
    end

    # add_concurrent_index(:system_note_metadata, :action)
  end

  def down
    # no-op
  end
end
