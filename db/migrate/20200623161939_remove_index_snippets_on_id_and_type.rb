# frozen_string_literal: true

class RemoveIndexSnippetsOnIdAndType < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    remove_concurrent_index :snippets, [:id, :created_at]
  end

  def down
    add_concurrent_index :snippets, [:id, :created_at]
  end
end
