# frozen_string_literal: true

class CreateEncryptedFiles < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :encrypted_files do |t|
      t.string :file
      t.text :key_ciphertext
    end
  end
end
