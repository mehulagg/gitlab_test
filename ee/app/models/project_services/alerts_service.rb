# frozen_string_literal: true

require 'securerandom'

class AlertsService < Service
  include Gitlab::Routing

  prop_accessor :url, :token

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
        type: 'text',
        name: 'url',
        required: true, # ???
        readonly: true
      },
      {
        type: 'text',
        name: 'token',
        required: true, # ???
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
