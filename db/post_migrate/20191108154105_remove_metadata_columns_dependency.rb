# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class RemoveMetadataColumnsDependency < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def up
    remove_column :packages_package_dependencies, :metadata
  end

  def down
    add_column :packages_package_dependencies, :metadata, :binary
  end
end
