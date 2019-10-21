class AddLastWikiUpdatedAtIndexToProject < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :projects, :last_wiki_updated_at
  end

  def down
    remove_index :projects, :last_wiki_updated_at if index_exists?(:projects, :last_wiki_updated_at)
  end
end
