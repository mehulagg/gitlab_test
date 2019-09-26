require 'settingslogic'
require 'digest/md5'

class BaseSettings < Settingslogic
  source ENV.fetch('GITLAB_CONFIG') { Pathname.new(File.expand_path('..', __dir__)).join('gitlab.yml') }
  namespace ENV.fetch('GITLAB_ENV') { Rails.env }

  def self.build_base_gitlab_url
    base_url(gitlab).join('')
  end

  private

  def self.base_url(config)
    custom_port = on_standard_port?(config) ? nil : ":#{config.port}"

    [
        protocol(config),
        "://",
        config.host,
        custom_port
    ]
  end

  def self.on_standard_port?(config)
    config.port.to_i == (config.https ? 443 : 80)
  end

  def self.protocol(config)
    config.https ? "https" : "http"
  end
end
