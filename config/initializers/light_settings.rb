require 'settingslogic'
require 'digest/md5'
require_dependency File.expand_path('base_settings', __dir__)

class LightSettings < BaseSettings
  source ENV.fetch('GITLAB_CONFIG') { Pathname.new(File.expand_path('..', __dir__)).join('gitlab.yml') }
  namespace ENV.fetch('GITLAB_ENV') { Rails.env }

  COM_URL = 'https://gitlab.com'.freeze
  SUBDOMAIN_REGEX = %r{\Ahttps://[a-z0-9]+\.gitlab\.com\z}.freeze

  class << self
    def com?
      build_base_gitlab_url == COM_URL || gl_subdomain?
    end

    private

    def gl_subdomain?
      SUBDOMAIN_REGEX === build_base_gitlab_url
    end
  end
end
