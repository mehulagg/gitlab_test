# frozen_string_literal: true

require_dependency File.expand_path('../lib/gitlab/utils/strong_memoize', __dir__)

class LightSettings
  GL_HOST = 'gitlab.com'
  GL_SUBDOMAIN_REGEX = %r{\A[a-z0-9]+\.gitlab\.com\z}.freeze

  class << self
    def com?
      Gitlab::Utils::StrongMemoize.strong_memoize(:is_com) do
        host == GL_HOST || gl_subdomain?
      end
    end

    private

    def config
      YAML.safe_load(File.read(settings_path), aliases: true)[Rails.env]
    end

    def settings_path
      Rails.root.join('config', 'gitlab.yml')
    end

    def host
      config['gitlab']['host']
    end

    def gl_subdomain?
      GL_SUBDOMAIN_REGEX === host
    end
  end
end
