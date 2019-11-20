# frozen_string_literal: true

class ExtendIndexStatusUniqueIndexToElasticsearchIndexId < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    # Remove the unique constraint from the project_id index
    remove_concurrent_index :index_statuses, :project_id, name: 'index_index_statuses_on_project_id'
    add_concurrent_index :index_statuses, :project_id

    # Add a combined unique constraint on project_id and elasticsearch_index_id
    add_concurrent_index :index_statuses, [:project_id, :elasticsearch_index_id], unique: true
  end

  def down
    # Remove the combined unique constraint
    remove_concurrent_index :index_statuses, [:project_id, :elasticsearch_index_id]

    # Add the unique constraint back to the project_id index
    remove_concurrent_index :index_statuses, :project_id, name: 'index_index_statuses_on_project_id'
    add_concurrent_index :index_statuses, :project_id, unique: true
  end
end
