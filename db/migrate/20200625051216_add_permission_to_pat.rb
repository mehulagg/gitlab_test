# frozen_string_literal: true

class AddPermissionToPat < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :personal_access_tokens, :permissions, :jsonb, default: {}, null: false
  end
end
