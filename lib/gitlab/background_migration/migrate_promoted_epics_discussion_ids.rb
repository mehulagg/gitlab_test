# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # This migration updates discussion ids for epics that were promoted from issue so that the discussion id on epics
    # is different from discussion id on issue, which was causing problems when repying to epic discussions as it would
    # identify the discussion as related to an issue and complaint about missing project_id
    class MigratePromotedEpicsDiscussionIds
      # notes model to itterate through the notes to be updated
      class Note < ActiveRecord::Base
        include EachBatch
        self.table_name = 'notes'
      end

      def perform(discussion_id)
        Note.where(noteable_type: 'Epic').where(discussion_id: discussion_id).update_all(discussion_id: Discussion.discussion_id(Note.new))
      end

      def perform_all_sync(batch_size:)
        fetch_discussion_ids_query.each_batch(of: batch_size) do |notes|
          notes.each do |note|
            perform(note[:discussion_id])
          end
        end
      end

      private

      def fetch_discussion_ids_query
        promoted_epics_query = Note
                                 .where(system: true)
                                 .where(noteable_type: 'Epic')
                                 .where("note LIKE 'promoted from%'")
                                 .select("DISTINCT noteable_id")
        Note.where(noteable_type: 'Epic')
          .where(noteable_id: promoted_epics_query)
          .select("DISTINCT discussion_id")
      end
    end
  end
end
