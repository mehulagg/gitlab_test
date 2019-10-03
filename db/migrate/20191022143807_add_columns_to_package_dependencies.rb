# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddColumnsToPackageDependencies < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def up
    add_column :packages_package_dependencies, :version_pattern, :string, limit: 255
    add_column :packages_package_dependencies, :name, :string, limit: 255
    remove_column :packages_package_dependencies, :metadata
    remove_index :packages_package_dependencies, :package_id
    add_index :packages_package_dependencies, :package_id

  def down
    remove_column :packages_package_dependencies, :version_pattern
    remove_column :packages_package_dependencies, :name
    add_column :packages_package_dependencies, :metadata, :binary
    remove_index :packages_package_dependencies, :package_id
    add_index :packages_package_dependencies, :package_id, unique: true
  end


  end
end
