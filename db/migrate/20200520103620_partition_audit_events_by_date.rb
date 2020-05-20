# frozen_string_literal: true

class PartitionAuditEventsByDate < ActiveRecord::Migration[6.0]
  include Gitlab::Database::PartitioningMigrationHelpers

  DOWNTIME = false

  def up
    execute 'CREATE SCHEMA partitions'

    partition_table_by_date :audit_events, :created_at,
      min_time: Time.utc(2014, 12, 1), max_time: Time.utc(2021, 1, 1)
  end

  def down
    drop_partitioned_table_for :audit_events

    execute 'DROP SCHEMA partitions'
  end
end
