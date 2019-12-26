# frozen_string_literal: true

class AddRetryStatusToImportFailures < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column_with_default(:import_failures, :retry_status, :integer, default: 0)
  end

  def down
    remove_column(:import_failures, :retry_status)
  end
end
