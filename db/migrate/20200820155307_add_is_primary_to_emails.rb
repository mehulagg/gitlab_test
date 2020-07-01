# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIsPrimaryToEmails < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :emails, :is_primary, :boolean, default: false, null: false

    add_concurrent_index :emails, [:user_id, :is_primary], unique: true, where: 'is_primary IS TRUE'
  end

  def down
    remove_column :emails, :is_primary
  end
end
