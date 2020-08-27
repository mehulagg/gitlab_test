# frozen_string_literal: true

class UpdateGroupImportStateUserId < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    say_with_time('Updating user_id in group_import_states') do
      GroupImportState.where('user_id IS NULL').find_each do |group_import_state|
        owner_id = Group.find(group_import_state.group_id).default_owner&.id

        group_import_state.update!(user_id: owner_id)
      end
    end
  end

  def down
    say_with_time('Reverting user_id in group_import_states') do
      GroupImportState.where('user_id IS NOT NULL').find_each do |group_import_state|
        group_import_state.update!(user_id: nil)
      end
    end
  end
end
