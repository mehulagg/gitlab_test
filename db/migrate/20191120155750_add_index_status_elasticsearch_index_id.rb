# frozen_string_literal: true

class AddIndexStatusElasticsearchIndexId < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  class ElasticsearchIndex < ActiveRecord::Base
    self.table_name = 'elasticsearch_indices'
  end

  class IndexStatus < ActiveRecord::Base
    self.table_name = 'index_statuses'
  end

  def up
    existing_index = ElasticsearchIndex.order(:id).first

    if existing_index
      # Backfill elasticsearch_index_id on existing records
      add_column_with_default :index_statuses, :elasticsearch_index_id, :integer, allow_null: false, default: existing_index.id
      change_column_default :index_statuses, :elasticsearch_index_id, nil
    else
      IndexStatus.delete_all
      add_column :index_statuses, :elasticsearch_index_id, :integer, null: false # rubocop:disable Rails/NotNullColumn
    end

    add_concurrent_foreign_key :index_statuses, :elasticsearch_indices, column: :elasticsearch_index_id
    add_concurrent_index :index_statuses, :elasticsearch_index_id
  end

  def down
    remove_column :index_statuses, :elasticsearch_index_id
  end
end
