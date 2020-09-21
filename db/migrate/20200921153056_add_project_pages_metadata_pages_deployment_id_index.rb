# frozen_string_literal: true

class AddProjectPagesMetadataPagesDeploymentIdIndex < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'idx_project_pages_metadata_on_pages_deployment_id'

  disable_ddl_transaction!

  def up
    add_concurrent_index :project_pages_metadata, :pages_deployment_id, name: INDEX_NAME
  end

  def down
    remove_concurrent_index :project_pages_metadata, :pages_deployment_id, name: INDEX_NAME
  end
end
