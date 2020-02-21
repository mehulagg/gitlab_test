# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddSprintToMergeRequests < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    # index will be added in another migration with `add_concurrent_index`
    add_column :merge_requests, :sprint_id, :bigint
    add_concurrent_foreign_key :merge_requests, :sprints, column: :sprint_id
  end

  def down
    remove_foreign_key :merge_requests, column: :sprint_id
    remove_column :merge_requests, :sprint_id
  end
end
