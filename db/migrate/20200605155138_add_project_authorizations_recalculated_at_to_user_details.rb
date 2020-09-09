# frozen_string_literal: true

class AddProjectAuthorizationsRecalculatedAtToUserDetails < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :user_details, :project_authorizations_recalculated_at, :datetime_with_timezone
    add_concurrent_index :user_details, :project_authorizations_recalculated_at
  end

  def down
    remove_concurrent_index :user_details, :project_authorizations_recalculated_at
    remove_column :user_details, :project_authorizations_recalculated_at
  end
end
