# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddGroupIdToImportFailures < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column(:import_failures, :group_id, :integer) unless group_id_exists?
    add_concurrent_foreign_key(:import_failures, :namespaces, column: :group_id)
    add_concurrent_index(:import_failures, :group_id)

    change_column_null :import_failures, :project_id, true
  end

  def down
    remove_foreign_key(:import_failures, column: :group_id)
    remove_concurrent_index(:import_failures, :group_id)
    remove_column(:import_failures, :group_id) if group_id_exists?

    change_column_null :import_failures, :project_id, false
  end

  private

  def group_id_exists?
    column_exists?(:import_failures, :group_id)
  end
end
