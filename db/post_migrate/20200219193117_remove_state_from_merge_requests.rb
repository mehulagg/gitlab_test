# frozen_string_literal: true

class RemoveStateFromMergeRequests < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    remove_column :merge_requests, :state, :string
  end
end
