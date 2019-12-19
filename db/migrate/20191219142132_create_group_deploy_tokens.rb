# frozen_string_literal: true

class CreateGroupDeployTokens < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    create_table :group_deploy_tokens do |t|
      t.bigint :group_id, null: false
      t.bigint :deploy_token_id, null: false
      t.datetime_with_timezone :created_at, null: false

      t.index [:group_id, :deploy_token_id], unique: true
      t.index [:deploy_token_id]
    end
  end
end
