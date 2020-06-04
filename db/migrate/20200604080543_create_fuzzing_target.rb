# frozen_string_literal: true

class CreateFuzzingTarget < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:fuzzing_targets)
      with_lock_retries do
        create_table :fuzzing_targets do |t|
          t.references :project, index: true, foreign_key: { on_delete: :cascade }, null: false
          t.text :name, null: false
        end
      end
    end

    add_text_limit :fuzzing_targets, :name, 255
  end

  def down
    drop_table :fuzzing_targets
  end
end
