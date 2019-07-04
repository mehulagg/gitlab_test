# frozen_string_literal: true

class RemoveDuplicatePackagesPackages < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    select_all("SELECT name, version, package_type, count(id) as cnt FROM packages_packages GROUP BY name, version, package_type HAVING COUNT(id) > 1").each do |pkg|
      duplicate_ids = select_all(
        "SELECT id FROM packages_packages WHERE name = '#{pkg['name']}' AND version = '#{pkg['version']}' AND package_type = '#{pkg['package_type']}' ORDER BY id ASC"
      ).map { |package| package['id'] }
      newest_package_id = duplicate_ids.last
      duplicate_ids.delete newest_package_id

      execute("DELETE FROM packages_packages WHERE id IN(#{duplicate_ids.join(",")})")
    end
  end

  def down
  end
end
