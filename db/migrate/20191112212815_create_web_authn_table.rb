# frozen_string_literal: true

class CreateWebAuthnTable < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  # DOWNTIME_REASON = ''

  # disable_ddl_transaction!

  def change
    create_table :webauthn_registrations do |t|
      t.references :user, type: :integer, foreign_key: { on_delete: :cascade, to_table: :users }

      t.bigint :counter, default: 0, null: false
      t.timestamps_with_timezone
      t.string :external_id, limit: 255, null: false
      t.string :name, limit: 255, null: false
      t.text :public_key, null: false

      t.index :external_id, unique: true
    end

    add_column :users, :webauthn_id, :string, limit: 86
  end
end
