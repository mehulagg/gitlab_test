# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddRetryToImportFailures < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column_with_default(:import_failures, :retry_count, :integer, default: 0)
    add_column_with_default(:import_failures, :retry_status, :integer, default: 0, limit: 2)
  end

  def down
    remove_columns :import_failures, :retry_count, :retry_status
  end
end
