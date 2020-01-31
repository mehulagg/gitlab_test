# frozen_string_literal: true

class VaultIntegration < ApplicationRecord
  belongs_to :project

  attr_encrypted :token,
    mode:      :per_attribute_iv,
    algorithm: 'aes-256-gcm',
    key:       Settings.attr_encrypted_db_key_base_32

  attr_encrypted :ssl_pem_contents,
    mode:      :per_attribute_iv,
    algorithm: 'aes-256-gcm',
    key:       Settings.attr_encrypted_db_key_base_32

  validates :project, presence: true
  validates :enabled, inclusion: { in: [true, false] }

  validates :vault_url,
            length: { maximum: 1024 },
            addressable_url: { enforce_sanitization: true, ascii_only: true }

  validates :token,            presence: true,
            unless: proc { |record| record.ssl_pem_contents.present? }

  validates :ssl_pem_contents, presence: true,
            unless: proc { |record| record.token.present? }

  scope :enabled, -> { where(enabled: true) }

  def client
    return unless enabled?

    @client ||= ::Vault::Client.new(**client_attributes)
  end

  def client_attributes
    {
      address: vault_url.chomp('/'),
      token: token.presence,
      ssl_pem_contents: ssl_pem_contents.presence,
      timeout: 5.seconds
    }.compact
  end
end
