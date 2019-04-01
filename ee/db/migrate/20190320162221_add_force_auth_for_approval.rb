# frozen_string_literal: true

class AddForceAuthForApproval < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :projects, :force_auth_for_approval, :boolean
  end
end
