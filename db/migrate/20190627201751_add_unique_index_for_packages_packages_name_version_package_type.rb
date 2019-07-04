# frozen_string_literal: true

class AddUniqueIndexForPackagesPackagesNameVersionPackageType < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :packages_packages, [:name, :version, :package_type], unique: true
  end

  def down
    remove_concurrent_index :packages_packages, [:name, :version, :package_type] if index_exists? :packages_packages, [:name, :version, :package_type]
  end
end
