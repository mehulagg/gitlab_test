# frozen_string_literal: true

class BackfillTargetTypeOnPushRules < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  MIGRATION = 'BackfillTargetTypeOnPushRules'.freeze
  BATCH_SIZE = 10_000
  INSTANCE_TYPE = 0

  class PushRules < ActiveRecord::Base
    include EachBatch

    self.table_name = 'push_rules'
    self.inheritance_column = :_type_disabled
  end

  def up
    BackfillTargetTypeOnPushRules::PushRules.where(is_sample: true).update_all(target_type: INSTANCE_TYPE)

    queue_background_migration_jobs_by_range_at_intervals(BackfillTargetTypeOnPushRules::PushRules,
                                                          MIGRATION,
                                                          5.minutes,
                                                          batch_size: BATCH_SIZE)
  end

  def down
    # no-op
  end
end
