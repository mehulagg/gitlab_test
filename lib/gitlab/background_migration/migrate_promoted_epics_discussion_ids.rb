# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # This migration updates discussion ids for epics that were promoted from issue so that the discussion id on epics
    # is different from discussion id on issue, which was causing problems when repying to epic discussions as it would
    # identify the discussion as related to an issue and complaint about missing project_id
    class MigratePromotedEpicsDiscussionIds
      # notes model to iterate through the notes to be updated
      class Note < ActiveRecord::Base
        self.table_name = 'notes'
      end

      def perform(discussion_ids)
        discussion_values = build_discussion_values(discussion_ids)

        update_notes_discussion_ids(discussion_values) if discussion_values
      end

      def build_discussion_values(discussion_ids)
        new_discussion_ids = discussion_ids.map {|old_id| [old_id, Discussion.discussion_id(Note.new)]}
        new_discussion_ids.map { |el| el.map { |id| Note.connection.quote_string(id) }.join("','") }.join("'), ('").prepend("('").concat("')")
      end

      def update_notes_discussion_ids(values)
        sql = <<-SQL.squish
          UPDATE notes SET discussion_id = v.new_discussion_id
          FROM (
            VALUES
            #{values}
          ) AS v(old_discussion_id, new_discussion_id)
          WHERE notes.discussion_id = v.old_discussion_id
          AND notes.noteable_type = 'Epic'
        SQL

        Note.connection.execute(sql)
      end
    end
  end
end
