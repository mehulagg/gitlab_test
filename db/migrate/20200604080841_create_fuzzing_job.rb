# frozen_string_literal: true

class CreateFuzzingJob < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  def up
    unless table_exists?(:fuzzing_jobs)
      with_lock_retries do
        create_table :fuzzing_jobs do |t|
          t.references :build,
                       null: false,
                       index: true,
                       foreign_key: { to_table: :ci_builds, on_delete: :cascade },
                       type: :bigint
          t.references :target,
                       null: false,
                       index: true,
                       foreign_key: { to_table: :fuzzing_targets, on_delete: :cascade },
                       type: :bigint
          t.integer :job_type,
                    null: false,
                    limit: 2
          t.integer :status,
                    null: true,
                    limit: 2
        end
      end
    end
  end

  def down
    drop_table :fuzzing_jobs
  end
end
