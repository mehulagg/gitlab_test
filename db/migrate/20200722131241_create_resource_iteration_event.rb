# frozen_string_literal: true

class CreateResourceIterationEvent < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :resource_iteration_events do |t|
      t.references :user, null: false, foreign_key: { on_delete: :nullify },
                   index: { name: 'index_resource_iteration_events_on_user_id' }
      t.references :issue, null: true, foreign_key: { on_delete: :cascade },
                   index: { name: 'index_resource_iteration_events_on_issue_id' }
      t.references :merge_request, null: true, foreign_key: { on_delete: :cascade },
                   index: { name: 'index_resource_iteration_events_on_merge_request_id' }
      t.references :iteration, foreign_key: { to_table: :sprints, on_delete: :cascade },
                   index: { name: 'index_resource_iteration_events_on_iteration_id' }

      t.integer :action, limit: 2, null: false
      t.datetime_with_timezone :created_at, null: false
    end
  end
end
