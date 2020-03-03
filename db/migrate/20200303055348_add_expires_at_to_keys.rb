# frozen_string_literal: true

class AddExpiresAtToKeys < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :keys, :expires_at, :date
  end
end
