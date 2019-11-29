# frozen_string_literal: true

class AddPersonalAccessTokenPrefixToApplicationSetting < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :application_settings, :personal_access_token_prefix, :string, null: true # rubocop:disable Migration/AddLimitToStringColumns
  end
end
