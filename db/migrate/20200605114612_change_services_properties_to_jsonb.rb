# frozen_string_literal: true

class ChangeServicesPropertiesToJsonb < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    change_column :services, :properties, :jsonb, default: {}, using: 'properties::jsonb'
  end

  def down
    change_column :services, :properties, :text, default: nil
  end
end
