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
        select_from = PushRule.where(id: start_id..stop_id).where(is_sample: false).select(:id, :project_id).to_sql

        ActiveRecord::Base.connection_pool.with_connection do |connection|
          connection.execute <<~SQL
            INSERT INTO project_push_rules (push_rule_id, project_id)
            #{select_from}
          SQL
        end
      end
    end
  end
end
