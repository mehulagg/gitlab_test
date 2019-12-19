# frozen_string_literal: true

class AddGeoRepositoryMovedEvent < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :geo_repository_moved_events do |t|
      t.references :project
      t.text :old_repository_storage, null: false
      t.text :new_repository_storage, null: false
    end

    change_table :geo_event_log do |t|
      t.references :repository_moved_event
    end
  end
end
