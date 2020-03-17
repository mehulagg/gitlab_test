# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Class that will insert record into project_push_rules
    # for each existing push_rule
    class MigratePushRules
      # Temporary AR table for push rules
      class PushRule < ActiveRecord::Base
        self.table_name = 'push_rules'
      end

      def perform(start_id, stop_id)
        records = PushRule.where(id: start_id..stop_id).where(is_sample: false).select(:id, :project_id)

        attributes = records.map { |record| { push_rule_id: record.id, project_id: record.project_id } }

        Gitlab::Database.bulk_insert(:project_push_rules, attributes)
      end
    end
  end
end
