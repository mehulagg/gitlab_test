# frozen_string_literal: true

require 'securerandom'

class AlertsService < Service
  include Gitlab::Routing

  prop_accessor :url, :authorization_key

  validates :url, :authorization_key, presence: true, if: :activated?

  after_initialize :ensure_authorization_key
  before_save :ensure_authorization_key

  def url
    # TODO use route url once defined
    project_url(project) + '/alerts/notify.json'
  end

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
        type: 'text',
        name: 'url',
        required: true, # ???
        readonly: true
      },
      {
        type: 'text',
        name: 'authorization_key',
        required: true, # ???
        readonly: true
      }
    ]
  end

  def self.supported_events
    %w()
  end

  private

  def ensure_authorization_key
    return if authorization_key.present?

    update!(authorization_key: generate_token)
  end

  def generate_token
    SecureRandom.hex
  end
end
