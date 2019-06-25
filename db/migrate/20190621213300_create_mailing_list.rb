# frozen_string_literal: true

class CreateMailingList < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_table "mailing_lists", id: :serial, force: :cascade do |t|
      t.belongs_to :project, null: false, index: { unique: true }, foreign_key: { on_delete: :cascade }
      t.string "email", null: false
    end

    create_table "mailing_list_subscriptions", id: :serial, force: :cascade do |t|
      t.belongs_to :mailing_list, null: false, index: { unique: false }, foreign_key: { on_delete: :cascade }
      t.string "user_email", null: false
    end

    create_table "mailing_list_pending_subscriptions", id: :serial, force: :cascade do |t|
      t.belongs_to :mailing_list, null: false, index: { unique: false }, foreign_key: { on_delete: :cascade }
      t.string "user_email", null: false
      t.string "confirmation_token", null: false
      t.datetime "expires_at", null: false
    end

    add_index :mailing_lists, [:email], unique: true
    add_index :mailing_list_subscriptions, [:mailing_list_id, :user_email], unique: true, name: "index_ml_subscriptions_on_ml_id_and_user_email"
    add_index :mailing_list_pending_subscriptions, [:mailing_list_id, :user_email], unique: true, name: "index_ml_pending_subscriptions_on_ml_id_and_user_email"
    add_index :mailing_list_pending_subscriptions, [:confirmation_token], unique: true
  end

  def down
    drop_table(:mailing_list_pending_subscriptions)
    drop_table(:mailing_list_subscriptions)
    drop_table(:mailing_lists)
  end
end
