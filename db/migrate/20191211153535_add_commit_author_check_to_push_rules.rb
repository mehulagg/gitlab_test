# frozen_string_literal: true

class AddCommitAuthorCheckToPushRules < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def up
    add_column :push_rules, :commit_author_check, :boolean
  end

  def down
    remove_column :push_rules, :commit_author_check, :boolean
  end
end
