# frozen_string_literal: true

class CreateUsersStatistics < ActiveRecord::Migration[6.0]
  DOWNTIME = false
  STATISTICS_NAMES = [
    :without_groups_and_projects,
    :highest_role_is_10,
    :highest_role_is_20,
    :highest_role_is_30,
    :highest_role_is_40,
    :highest_role_is_50,
    :bots,
    :blocked
  ]

  def change
    create_table :users_statistics do |t|
      t.timestamps_with_timezone null: false
      t.datetime_with_timezone :as_at, null: false

      STATISTICS_NAMES.each do |statistics_name|
        t.integer statistics_name, null: false, default: 0
      end
    end
  end
end
