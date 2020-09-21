# frozen_string_literal: true

class RemoveDuplicateClusterAgentsIndex < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    remove_concurrent_index :cluster_agents, :project_id
  end

  def down
    add_concurrent_index :cluster_agents, :project_id
  end
end
