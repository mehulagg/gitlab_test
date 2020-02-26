# frozen_string_literal: true

class CreateJobVariablesDotenvTable < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :ci_build_dotenv_variables do |t|
      t.string :key, null: false, limit: 255
      t.text :encrypted_value
      t.string :encrypted_value_iv, limit: 255
      t.datetime_with_timezone :created_at, null: false
      t.references :build, foreign_key: { to_table: :ci_builds, on_delete: :cascade }, null: false, index: false
      t.index %i[build_id key], unique: true
    end
  end
end
