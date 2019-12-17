# frozen_string_literal: true

class AddPayloadToGeoEventLog < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    add_column :geo_event_log, :payload, :jsonb
  end
end
