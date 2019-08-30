# frozen_string_literal: true

class CreateElasticsearchIndices < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :elasticsearch_indices do |t|
      t.timestamps_with_timezone
      t.integer :shards, default: 5, null: false
      t.integer :replicas, default: 1, null: false
      t.boolean :aws, null: false, default: false
      t.string :name, null: false, limit: 255, index: { unique: true }
      t.string :friendly_name, null: false, limit: 255, index: { unique: true }
      t.string :version, null: false, limit: 255
      # rubocop:disable Migration/AddLimitToStringColumns
      t.string :urls, array: true, null: false, default: []
      t.string :aws_region
      t.string :aws_access_key
      t.string :encrypted_aws_secret_access_key
      t.string :encrypted_aws_secret_access_key_iv, limit: 255
      # rubocop:enable Migration/AddLimitToStringColumns
    end

    change_table :application_settings do |t|
      t.references :elasticsearch_read_index,
        index: true, foreign_key: { to_table: :elasticsearch_indices, on_delete: :nullify }
    end
  end
end
