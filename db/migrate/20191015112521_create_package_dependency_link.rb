# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreatePackageDependencyLink < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def change
    create_table :packages_package_dependency_links do |t|
      t.references :package, index: true, null: false, foreign_key: { to_table: :packages_packages, on_delete: :cascade }, type: :integer
      t.references :package_dependency, index: { name: 'index_packages_package_dependency_links_on_dependency_id' }, null: false, foreign_key: { to_table: :packages_package_dependencies, on_delete: :cascade }, type: :integer
      t.integer :dependency_type
    end
  end
end
