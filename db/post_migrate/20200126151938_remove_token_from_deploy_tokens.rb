# frozen_string_literal: true

class RemoveTokenFromDeployTokens < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    remove_column :deploy_tokens, :token, :string
  end
end
