# frozen_string_literal: true

class AddAllowForkPipelinesToRunInParent < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column_with_default :project_ci_cd_settings, :allow_fork_pipelines_to_run_in_parent, :boolean, allow_null: false, default: false
  end

  def down
    remove_column :project_ci_cd_settings, :allow_fork_pipelines_to_run_in_parent
  end
end
