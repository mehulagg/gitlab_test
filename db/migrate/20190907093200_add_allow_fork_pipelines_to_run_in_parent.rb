# frozen_string_literal: true

class AddAllowForkPipelinesToRunInParent < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    add_column :project_ci_cd_settings, :allow_fork_pipelines_to_run_in_parent, :boolean, default: false
  end

  def down
    remove_column :project_ci_cd_settings, :allow_fork_pipelines_to_run_in_parent
  end
end
