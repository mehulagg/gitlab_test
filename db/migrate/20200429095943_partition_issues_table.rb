# frozen_string_literal: true

class PartitionIssuesTable < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    execute 'DROP DATABASE IF EXISTS shard1'
    execute 'DROP DATABASE IF EXISTS shard2'
    execute 'CREATE DATABASE shard1'
    execute 'CREATE DATABASE shard2'

    ActiveRecord::Base.transaction do
      execute 'DROP TABLE IF EXISTS issues CASCADE'
      execute File.read(File.join(__dir__, '20200429095943_partition_issues_table.up.sql'))
    end
  end

  def down
    ActiveRecord::Base.transaction do
      execute 'DROP TABLE IF EXISTS issues CASCADE'
      execute File.read(File.join(__dir__, '20200429095943_partition_issues_table.down.sql'))
    end

    execute 'DROP DATABASE IF EXISTS shard1'
    execute 'DROP DATABASE IF EXISTS shard2'
  end
end
