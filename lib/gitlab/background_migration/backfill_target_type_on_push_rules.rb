# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Class that will backfill the `target_type` of `PushRule` records
    class BackfillTargetTypeOnPushRules
      PROJECT_TYPE = 1

      def perform(start_id, stop_id)
        PushRule.where(id: start_id..stop_id).where.not(is_sample: true).update_all(target_type: PROJECT_TYPE)
      end
    end
  end
end
