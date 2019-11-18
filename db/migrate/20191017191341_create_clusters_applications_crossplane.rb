# frozen_string_literal: true

class CreateClustersApplicationsCrossplane < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    create_table :clusters_applications_crossplane, id: false, primary_key: :cluster_id do |t|
      t.timestamps_with_timezone null: false
      t.integer :cluster_id, null: false, primary_key: true, default: nil
      t.integer :status, null: false
      t.string :version, null: false, limit: 255
      t.string :stack, null: false, limit: 255
      t.text :status_reason

      t.foreign_key :clusters, column: :cluster_id, on_delete: :cascade
    end
  end
end
