# frozen_string_literal: true

class AddConfirmationEmailVerificationTokenToUser < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    add_column :users, :confirmation_email_verification_token, :string, null: true, limit: 255
    add_concurrent_index :users, :confirmation_email_verification_token, unique: true
  end

  def down
    remove_column :users, :confirmation_email_verification_token
    remove_concurrent_index :users, :confirmation_email_verification_token
  end
end
