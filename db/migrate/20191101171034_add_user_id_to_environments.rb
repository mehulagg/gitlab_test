# frozen_string_literal: true

class AddUserIdToEnvironments < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :environments, :user_id, type: :bigint
  end
end
