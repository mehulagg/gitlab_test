# frozen_string_literal: true
#
class AddElasticsearchMaxBulkSizeCountToApplicationSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :application_settings, :elasticsearch_max_bulk_size_count, :integer, null: false, default: 1000
  end
end
