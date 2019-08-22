# frozen_string_literal: true

class AddValueEncryptedToCiVariables < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    add_column :ci_variables, :secret_encrypted, :string
  end

  def down
    remove_column :ci_variables, :secret_encrypted
  end
end
