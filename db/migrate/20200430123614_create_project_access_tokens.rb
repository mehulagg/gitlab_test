# frozen_string_literal: true

class CreateProjectAccessTokens < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :project_access_tokens do |t|
      t.references :project, foreign_key: true
      t.references :personal_access_token, foreign_key: true
    end
  end
end
