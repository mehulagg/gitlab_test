# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddWebIdeOnlyToCiRunners < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column_with_default(:ci_runners, :web_ide_only, :boolean,
                            default: false, allow_null: false)
  end

  def down
    remove_column(:ci_runners, :web_ide_only)
  end
end
