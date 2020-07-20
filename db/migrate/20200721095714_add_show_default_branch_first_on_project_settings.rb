class AddShowDefaultBranchFirstOnProjectSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_column :project_settings, :show_default_branch_first, :boolean, default: true, null: false
  end
end
