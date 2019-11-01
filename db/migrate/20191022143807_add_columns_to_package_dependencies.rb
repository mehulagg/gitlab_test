# frozen_string_literal: true
# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddColumnsToPackageDependencies < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def up
    add_column :packages_package_dependencies, :version_pattern, :string, limit: 255
  end

  def down
    add_column :packages_package_dependencies, :name, :string, limit: 255
    add_column :packages_package_dependencies, :metadata, :binary
  end
end
