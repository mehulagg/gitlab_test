# frozen_string_literal: true

class UpdateMinimumPasswordLength < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def up
    application_setting = ApplicationSetting.current_without_cache
    return unless application_setting

    value_to_be_updated_to = [
      Devise.password_length.min,
      ApplicationSetting::DEFAULT_MINIMUM_PASSWORD_LENGTH
    ].max

    application_setting.update(minimum_password_length: value_to_be_updated_to)
  end

  def down
    # application_setting = ApplicationSetting.current_without_cache
    # return unless application_setting

    # value_to_be_updated_to = ApplicationSetting::DEFAULT_MINIMUM_PASSWORD_LENGTH

    # application_setting.update(minimum_password_length: value_to_be_updated_to)
  end
end
