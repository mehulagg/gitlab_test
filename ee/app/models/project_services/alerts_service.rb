# frozen_string_literal: true

require 'securerandom'

class AlertsService < Service
  include Gitlab::Routing

  prop_accessor :url

  prop_accessor :encrypted_token, :encrypted_token_iv, :encrypted_token_salt
  attr_encrypted :token,
    mode: :per_attribute_iv,
    key: Settings.attr_encrypted_db_key_base_truncated,
    algorithm: 'aes-256-gcm'

  validates :url, presence: true, if: :activated?
  validates :token, presence: true, if: :activated?

  after_initialize :assign_url
  after_initialize :ensure_token

  before_validation :assign_url
  before_validation :ensure_token

  def editable?
    true
  end

  def can_test?
    false
  end

  def title
    'Alerts endpoint'
  end

  def description
    'Receive alerts on GitLab from any source'
  end

  def detailed_description
    "Each alert source must be authorized using the following URL and authorization key. Learn more about configuring this endpoint to receive alerts."
  end

  def self.to_param
    'alerts'
  end

  def fields
    [
      {
        type: 'readonly_text',
        name: 'url',
        required: true,
        readonly: true
      },
      {
        type: 'readonly_text',
        name: 'token',
        required: true,
        readonly: true
      }
    ]
  end

  def self.supported_events
    %w()
  end

  private

  def ensure_token
    self.token = generate_token if token.blank?
  end

  def generate_token
    SecureRandom.hex
  end

  def assign_url
    self.url = generate_url
  end

  def generate_url
    # TODO use route url once defined
    project_url(project) + '/alerts/notify.json'
  end
end
