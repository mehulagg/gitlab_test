# frozen_string_literal: true

class CreateFuzzingCrash < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:fuzzing_crashes)
      with_lock_retries do
        create_table :fuzzing_crashes do |t|
          t.references :job,
                       null: false,
                       index: true,
                       foreign_key: { to_table: :fuzzing_jobs, on_delete: :cascade },
                       type: :bigint
          t.integer :exit_code, null: false, limit: 2
          t.integer :crash_type, null: false, limit: 2
          t.text :state, null: true
          t.text :stack_trace, null: true
        end
      end
    end

    add_text_limit :fuzzing_crashes, :state, 1023
    add_text_limit :fuzzing_crashes, :stack_trace, 1023
  end

  def down
    drop_table :fuzzing_crashes
  end
end
