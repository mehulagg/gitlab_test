# frozen_string_literal: true

class AddIndexesToGeoRepositoryMovedEvents < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key :geo_event_log, :geo_repository_moved_events,
                               column: :repository_moved_event_id,
                               name: 'fk_geo_event_log_on_repository_moved_event_id'

    add_concurrent_index :geo_event_log, :repository_moved_event_id,
                         where: "(repository_moved_event_id IS NOT NULL)",
                         using: :btree,
                         name: 'index_geo_event_log_on_repository_moved_event_id'
  end

  def down
    remove_concurrent_index :geo_event_log, :repository_moved_event_id, name: 'index_geo_event_log_on_repository_moved_event_id'

    remove_foreign_key_without_error :geo_event_log, column: :repository_moved_event_id, name: 'fk_geo_event_log_on_repository_moved_event_id'
  end
end
