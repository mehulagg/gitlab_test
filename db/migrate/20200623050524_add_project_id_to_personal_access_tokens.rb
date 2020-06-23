# frozen_string_literal: true

class AddProjectIdToPersonalAccessTokens < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :personal_access_tokens, :project_id, :bigint
  end
end
