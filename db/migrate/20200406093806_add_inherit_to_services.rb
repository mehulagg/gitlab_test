# frozen_string_literal: true

class AddInheritToServices < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column(:services, :inherit, :boolean)
  end

  def down
    remove_column(:services, :inherit)
  end
end
