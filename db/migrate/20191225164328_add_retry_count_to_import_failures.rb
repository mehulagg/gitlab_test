# frozen_string_literal: true

class AddRetryCountToImportFailures < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    add_column(:import_failures, :retry_count, :integer, default: 0, null: false)
  end
end
