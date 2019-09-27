# frozen_string_literal: true

class CreateProjectStatisticsEvents < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    create_table :project_statistics_events do |t|
      t.references :project_statistics, foreign_key: { on_delete: :cascade }, null: false
      t.bigint :build_artifacts_size, default: 0, null: false
      t.datetime :created_at, null: false
    end
  end
end
