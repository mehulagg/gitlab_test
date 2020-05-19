# frozen_string_literal: true

class AddErrorMessageColumnToJiraImports < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  disable_ddl_transaction!

  def up
    add_column :jira_imports, :error_message, :text

    add_text_limit :jira_imports, :error_message, 1000
  end

  def down
    remove_column :jira_imports, :error_message
  end
end
