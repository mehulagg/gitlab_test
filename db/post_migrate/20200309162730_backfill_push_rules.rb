# frozen_string_literal: true

class BackfillPushRules < ActiveRecord::Migration[6.0]
  MIGRATION = 'BackfillPushRules'.freeze
  BATCH_SIZE = 10_000

  class PushRules < ActiveRecord::Base
    include EachBatch

    self.table_name = 'push_rules'
    self.inheritance_column = :_type_disabled
  end

  def up
    BackfillPushRules::PushRules.each_batch do |relation|
      queue_background_migration_jobs_by_range_at_intervals(relation,
                                                            MIGRATION,
                                                            5.minutes,
                                                            batch_size: BATCH_SIZE)
    end
  end

  def down
    # no-op
  end
end
