# frozen_string_literal: true

class CreateMergeRequestTrainsTable < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :merge_trains, id: :bigserial do |t|
      t.references :project, foreign_key: { on_delete: :cascade }, index: false, null: false
      t.references :merge_request, foreign_key: { on_delete: :cascade }, index: false, null: false
      t.string :target_branch, null: false
      t.integer :iid, null: false

      t.index [:project_id, :merge_request_id], unique: true
      t.index [:project_id, :target_branch, :iid], unique: true
    end
  end
end
