# frozen_string_literal: true

class RemoveStateFromIssues < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    remove_column :issues, :state, :string
  end
end
