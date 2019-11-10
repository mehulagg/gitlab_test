# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class RenamePackageMetadataTable < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def up
    rename_table :packages_package_metadata, :packages_package_dependencies
  end

  def down
    rename_table :packages_package_dependencies, :packages_package_metadata
  end
end
