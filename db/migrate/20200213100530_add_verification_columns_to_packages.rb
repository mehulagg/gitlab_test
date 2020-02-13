# frozen_string_literal: true

class AddVerificationColumnsToPackages < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :packages_packages, :verification_retry_at, :datetime_with_timezone
    add_column :packages_packages, :last_verification_ran_at, :datetime_with_timezone
    add_column :packages_packages, :verification_checksum, :string
    add_column :packages_packages, :verification_failure, :string
    add_column :packages_packages, :verification_retry_count, :integer
  end
end
