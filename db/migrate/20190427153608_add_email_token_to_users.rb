# frozen_string_literal: true

class AddEmailTokenToUsers < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :users, :email_token, :string

    add_concurrent_index :users, :email_token
  end

  def down
    remove_concurrent_index :users, :email_token if index_exists? :users, :email_token

    remove_column :users, :email_token
  end
end
