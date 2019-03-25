# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddSourceProjectFkToPipelines < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  # To disable transactions uncomment the following line and remove these
  # comments:
  disable_ddl_transaction!

  def up
    add_concurrent_index :ci_pipelines, :source_project_id
    add_concurrent_foreign_key :ci_pipelines, :ci_sources_projects, column: :source_project_id, on_delete: :nullify
  end

  def down
    remove_foreign_key :ci_pipelines, column: :source_project_id
    remove_concurrent_index :ci_pipelines, :source_project_id
  end
end
