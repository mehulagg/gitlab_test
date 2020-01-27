class CreateVaultIntegrations < ActiveRecord::Migration[5.2]
  def change
    create_table :vault_integrations do |t|
      t.references :project, foreign_key: true
      t.boolean :enabled, default: false, null: false
      t.string :vault_url, limit: 1024, null: false

      t.string :encrypted_token, limit: 255
      t.string :encrypted_token_iv, limit: 255
      t.string :encrypted_ssl_pem_contents_iv, limit: 255
      t.text :encrypted_ssl_pem_contents, limit: 8.kilobytes # certificate + private key
      t.text :protected_secrets, limit: 1024, array: true

      t.timestamps_with_timezone
    end
    add_index :vault_integrations, :enabled
  end
end
