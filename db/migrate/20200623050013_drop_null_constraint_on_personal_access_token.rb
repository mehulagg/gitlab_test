# frozen_string_literal: true

class DropNullConstraintOnPersonalAccessToken < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    change_column_null :personal_access_tokens, :user_id, true
  end

  def down
    # No-op -- null values could have been added after this this constraint was removed.
  end
end
