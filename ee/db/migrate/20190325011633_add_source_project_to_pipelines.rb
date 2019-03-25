# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddSourceProjectToPipelines < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def up
    add_column :ci_pipelines, :source_project_id, :integer
  end

  def down
    remove_column :ci_pipelines, :source_project_id
  end
end
