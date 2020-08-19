# frozen_string_literal: true

class CleanupServiceDeskReplyToRename < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    cleanup_concurrent_column_rename :issues, :service_desk_reply_to, :external_author
  end

  def down
    undo_cleanup_concurrent_column_rename :issues, :service_desk_reply_to, :external_author
  end
end
