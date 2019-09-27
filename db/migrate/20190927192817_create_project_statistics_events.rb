# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateProjectStatisticsEvents < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    # TODO: add index for [project_statistics_id, attribute_name]
    create_table :project_statistics_events do |t|
      t.references :project_statistics, foreign_key: { on_delete: :cascade }, null: false
      t.string :attribute_name, limit: 50, null: false
      t.integer :value, null: false
      t.datetime :created_at, null: false
    end
  end
end
