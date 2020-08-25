# frozen_string_literal: true

class CreateMergeRequestReviewers < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :merge_request_reviewers do |t|
      t.references :user, foreign_key: { on_delete: :cascade }, index: true, null: false
      t.references :merge_request, foreign_key: { on_delete: :cascade }, index: true, null: false
      t.datetime_with_timezone :created_at, null: false
    end
  end
end
