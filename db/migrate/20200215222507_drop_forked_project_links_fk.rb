# frozen_string_literal: true

class DropForkedProjectLinksFk < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      remove_foreign_key_if_exists :forked_project_links, column: :forked_to_project_id
    end
  end

  def down
    add_concurrent_foreign_key :forked_project_links, :projects, column: :forked_to_project_id, on_delete: :cascade
  end
end
