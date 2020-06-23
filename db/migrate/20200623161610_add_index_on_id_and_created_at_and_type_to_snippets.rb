# frozen_string_literal: true

class AddIndexOnIdAndCreatedAtAndTypeToSnippets < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :snippets, [:id, :created_at, :type]
  end

  def down
    remove_concurrent_index :snippets, [:id, :created_at, :type]
  end
end
