# frozen_string_literal: true

class CreateLaunchTypes < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:launch_types)
      with_lock_retries do
        create_table :launch_types do |t|
          t.references :project, foreign_key: true, null: false
          t.text :deploy_target_type, null: false
          t.timestamps_with_timezone null: false
        end
      end
    end

    add_text_limit :launch_types, :deploy_target_type, 255
  end

  def down
    with_lock_retries do
      drop_table :launch_types
    end
  end
end
