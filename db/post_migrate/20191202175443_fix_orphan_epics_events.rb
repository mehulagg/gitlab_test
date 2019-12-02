# frozen_string_literal: true

class FixOrphanEpicsEvents < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  class Event < ActiveRecord::Base
    include EachBatch
  end

  def up
    return unless Gitlab::Database.postgresql?

    disable_statement_timeout do
      relation =
        Event
          .joins("INNER JOIN notes ON notes.id = events.target_id AND events.target_type = 'Note'")
          .where('events.group_id IS NULL')
          .where('events.project_id IS NULL')
          .where("notes.noteable_type ='Epic'")
          .where("events.target_type = 'Note'")
          .select('id')

      relation.each_batch do |events|
        query =
          <<-SQL.strip_heredoc
            UPDATE events
            SET group_id = epics.group_id
            FROM notes
            INNER JOIN epics ON epics.id = notes.noteable_id AND notes.noteable_type = 'Epic'
            WHERE events.target_type = 'Note'
            AND notes.id = events.target_id
            AND events.id IN (#{events.to_sql})
          SQL

        execute(query)
      end
    end
  end

  def down
    # No op
  end
end
