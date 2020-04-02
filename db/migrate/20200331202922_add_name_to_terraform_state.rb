# frozen_string_literal: true

class AddNameToTerraformState < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column(:terraform_states, :name, :string, limit: 255) unless column_exists?(:terraform_states, :name)
    add_concurrent_index(:terraform_states, :name)
  end

  def down
    remove_column(:terraform_states, :name) if column_exists?(:terraform_states, :name)
  end
end
