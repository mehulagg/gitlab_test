# frozen_string_literal: true

class AddIndexOfAuthorIdForDiffNotes < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index(
      :notes,
      [:author_id, :created_at],
      where: "type = 'DiffNote'",
      name: "index_diff_notes_on_author_id_and_created_at"
    )
  end

  def down
    remove_concurrent_index :notes, :index_diff_notes_on_author_id_and_created_at
  end
end
