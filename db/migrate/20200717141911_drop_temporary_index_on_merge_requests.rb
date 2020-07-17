# frozen_string_literal: true

class DropTemporaryIndexOnMergeRequests < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    remove_concurrent_index_by_name :merge_requests, name: 'merge_request_mentions_temp_index'
  end

  def down
    add_concurrent_index :merge_requests, :id, where: '(description ~~ \'%@%\'::text) OR ((title)::text ~~ \'%@%\'::text)', name: 'merge_request_mentions_temp_index'
  end
end
