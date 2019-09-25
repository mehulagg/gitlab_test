require 'settingslogic'
require 'digest/md5'

class LightSettings < Settingslogic
  source ENV.fetch('GITLAB_CONFIG') { Pathname.new(File.expand_path('..', __dir__)).join('gitlab.yml') }
  namespace ENV.fetch('GITLAB_ENV') { Rails.env }
  COM_URL = 'https://gitlab.com'
  SUBDOMAIN_REGEX = %r{\Ahttps://[a-z0-9]+\.gitlab\.com\z}.freeze

  class << self
    def com?
      puts "#{gitlab.host} | #{gitlab.port} | #{gitlab.https}"
      build_base_gitlab_url == COM_URL || gl_subdomain?
    end

    def build_base_gitlab_url
      base_url(gitlab).join('')
    end

    private

    def base_url(config)
      custom_port = on_standard_port?(config) ? nil : ":#{config.port}"

      [
          protocol(config),
          "://",
          config.host,
          custom_port
      ]
    end

    def on_standard_port?(config)
      config.port.to_i == (config.https ? 443 : 80)
    end

    def protocol(config)
      config.https ? "https" : "http"
    end

    def gl_subdomain?
      SUBDOMAIN_REGEX === build_base_gitlab_url
    end
  end
end
