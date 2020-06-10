# frozen_string_literal: true

class AddIndexLabelLinksIssuesCreatedAt < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_label_links_issues_created_at'

  disable_ddl_transaction!

  def up
    add_concurrent_index :label_links, [:id, :created_at],
      where: "target_type = 'Issue'",
      name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :label_links, INDEX_NAME
  end
end
