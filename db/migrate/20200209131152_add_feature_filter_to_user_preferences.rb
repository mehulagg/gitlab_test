# frozen_string_literal: true

class AddFeatureFilterToUserPreferences < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :user_preferences, :feature_filter, :bigint
  end
end
