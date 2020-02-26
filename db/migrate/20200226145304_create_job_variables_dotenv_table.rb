# frozen_string_literal: true

class CreateJobVariablesDotenvTable < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  DEFAULT_VARIBLE_TYPE_ENV_VAR = 1

  def change
    create_table :ci_build_dotenv_variables do |t|
      t.string :key, null: false, limit: 255
      t.text :encrypted_value
      t.string :encrypted_value_iv, limit: 255
      t.datetime_with_timezone :created_at, null: false
      t.references :build, foreign_key: { to_table: :ci_builds, on_delete: :cascade }, null: false, index: false
      t.integer :variable_type, null: false, limit: 2, default: DEFAULT_VARIBLE_TYPE_ENV_VAR
      t.index %i[build_id key], unique: true
    end
  end
end
