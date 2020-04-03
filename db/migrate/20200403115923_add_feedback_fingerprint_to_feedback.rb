# frozen_string_literal: true

class AddFeedbackFingerprintToFeedback < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :vulnerability_feedback, :feedback_fingerprint, :binary
    end
  end

  def down
    with_lock_retries do
      remove_column :vulnerability_feedback, :feedback_fingerprint
    end
  end
end
