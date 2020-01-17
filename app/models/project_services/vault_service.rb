# frozen_string_literal: true

class VaultService < Service
  prop_accessor :vault_url, :token

  # `public_url: false` to allow local development
  validates :vault_url, presence: true, public_url: false, if: :activated?
  validates :token, presence: true, if: :activated?

  def title
    s_('VaultService|Vault')
  end

  def description
    s_('VaultService|A tool for secrets management, encryption as a service, and privileged access management')
  end

  def self.to_param
    'vault'
  end

  def fields
    [
      {
        type: 'text',
        name: 'vault_url',
        placeholder: s_('VaultService|The URL of the Vault server'),
        required: true
      },
      {
        type: 'text',
        name: 'token',
        placeholder: 'Server token',
        required: true
      }
    ]
  end

  # TODO
  def test(_data)
    { success: true }
  end

  def execute(_data)
  end

  def self.supported_events
    %w()
  end

  def client
    @client ||= Vault::Client.new(address: vault_url, token: token)
  end
end
