# frozen_string_literal: true

class AlertsService < Service
  prop_accessor :authorization_key, :url
  validates :authorization_key, :url, presence: true, if: :activated?

  def editable?
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
end
