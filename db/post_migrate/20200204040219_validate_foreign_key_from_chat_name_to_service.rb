# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class ValidateForeignKeyFromChatNameToService < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  def up
    validate_foreign_key :chat_names, :service_id
  end

  def down
    # no-op
  end
end
