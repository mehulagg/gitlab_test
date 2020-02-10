# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddInvalidForeignKeyFromChatNameToService < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key :chat_names, :services, column: :service_id, on_delete: :cascade, validate: false
  end

  def down
    remove_foreign_key_if_exists :chat_names, column: :service_id
  end
end
