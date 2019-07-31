# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # This migration updates discussion ids for epics that were promoted from issue so that the discussion id on epics
    # is different from discussion id on issue, which was causing problems when repying to epic discussions as it would
    # identify the discussion as related to an issue and complaint about missing project_id
    class FixPromotedEpicsDiscussionIds
      # notes model to iterate through the notes to be updated
      class Note < ActiveRecord::Base
        self.table_name = 'notes'
      end

      # epics model we iterate through in batches
      class Epic < ActiveRecord::Base
        self.table_name = 'epics'
      end

      def perform(start_id, stop_id)
        discussion_ids = fetch_discussion_ids_query(start_id, stop_id)
        update_notes_discussion_ids(discussion_ids) unless discussion_ids.empty?
      end

      private

      def fetch_discussion_ids_query(start_id, stop_id)
        promoted_epics_query = Note
                                 .where(system: true)
                                 .where(noteable_type: 'Epic')
                                 .where(noteable_id: start_id..stop_id)
                                 .where("note LIKE 'promoted from%'")
                                 .select("DISTINCT noteable_id")

        Note.where(noteable_type: 'Epic')
          .where(noteable_id: promoted_epics_query)
          .select("DISTINCT discussion_id").order(:discussion_id)
      end

      def update_notes_discussion_ids(discussion_ids)
        Note.where(discussion_id: discussion_ids)
          .update_all("discussion_id=MD5(discussion_id)||substring(discussion_id from 1 for 8)")
      end
    end
  end
end
