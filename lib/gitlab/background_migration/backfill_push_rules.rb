# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Class that will backfill the `target_type` of `PushRule` records
    class BackfillPushRules
      TABLE = 'push_rules'
      TYPE = 'target_type'
      TYPES_HASH = { instance: 0, project: 1 }.freeze

      def perform(start_id, stop_id)
        connection.execute <<-SQL.strip_heredoc
          UPDATE #{TABLE}
          SET #{TYPE} = CASE WHEN is_sample IS true THEN #{TYPES_HASH[:instance]}
                                    ELSE #{TYPES_HASH[:project]}
                               END
          WHERE id BETWEEN #{start_id} AND #{stop_id}
        SQL
      end

      def connection
        ActiveRecord::Base.connection
      end
    end
  end
end
