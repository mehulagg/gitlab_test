# frozen_string_literal: true

class AddMinimumPasswordLengthToApplicationSettings < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  DEFAULT_MINIMUM_PASSWORD_LENGTH = 8

  def up
    add_column(:application_settings, :minimum_password_length, :integer, default: DEFAULT_MINIMUM_PASSWORD_LENGTH, null: false)
  end

  def down
    remove_column(:application_settings, :minimum_password_length)
  end
end
