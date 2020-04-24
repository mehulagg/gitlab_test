# frozen_string_literal: true

class CreateJiraSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :jira_settings do |t|
      t.references :project, foreign_key: { on_delete: :cascade }, type: :integer, index: true
      t.timestamps_with_timezone
      t.text :encrypted_url
      t.text :encrypted_url_iv
      t.text :encrypted_api_url
      t.text :encrypted_api_url_iv
      t.text :encrypted_username
      t.text :encrypted_username_iv
      t.text :encrypted_password
      t.text :encrypted_password_iv
      t.text :jira_issue_transition_identifier
      t.boolean :active, default: false
      t.boolean :merge_requests_events, default: true
      t.boolean :commit_events, default: true
      t.boolean :comment_on_event_enabled, default: true
      t.boolean :instance, default: false, null: false
    end

    add_text_limit :jira_settings,  :encrypted_url, 255
    add_text_limit :jira_settings,  :encrypted_url_iv, 255
    add_text_limit :jira_settings,  :encrypted_api_url, 255
    add_text_limit :jira_settings,  :encrypted_api_url_iv, 255
    add_text_limit :jira_settings,  :encrypted_username, 255
    add_text_limit :jira_settings,  :encrypted_username_iv, 255
    add_text_limit :jira_settings,  :encrypted_password, 255
    add_text_limit :jira_settings,  :encrypted_password_iv, 255
    add_text_limit :jira_settings,  :jira_issue_transition_identifier, 255
  end

  def down
    drop_table :jira_settings
  end
end
