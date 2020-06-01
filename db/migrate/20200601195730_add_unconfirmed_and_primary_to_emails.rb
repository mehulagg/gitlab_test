# frozen_string_literal: true

class AddUnconfirmedAndPrimaryToEmails < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  # rubocop:disable Migration/AddLimitToTextColumns
  # limit is added in 20200601200204_add_unconfirmed_text_limit_to_emails
  def change
    add_column :emails, :unconfirmed_email, :text
    add_column :emails, :is_primary, :boolean, default: false, null: false

    add_index(:emails, [:user_id, :is_primary], unique: true, where: 'is_primary IS TRUE')
  end
  # rubocop:enable Migration/AddLimitToTextColumns
end
