# frozen_string_literal: true

class AddRepoUrlToCiPipelines < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :ci_pipelines, :repo_url, :text
  end

  def down
    add_column :ci_pipelines, :repo_url, :text
  end
end
