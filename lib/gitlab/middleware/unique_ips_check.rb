# frozen_string_literal: true

module Gitlab
  module Middleware
    class UniqueIpsCheck
      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) unless Gitlab::CurrentSettings.current_application_settings.unique_ips_limit_enabled?

        request = ActionDispatch::Request.new(env)
        authenticator = Gitlab::Auth::RequestAuthenticator.new(request)
        user = authenticator.user([])

        Gitlab::Auth::UniqueIpsLimiter.limit_user!(user) if user

        @app.call(env)
      rescue ::Gitlab::Auth::TooManyIps => e
        Gitlab::AuthLogger.error(
          message: 'RateLimit_TooManyIps',
          remote_ip: e.ip,
          user_id: e.user_id,
          unique_ips_count: e.unique_ips_count)
        [429, {}, ['Too many requests from this IP']]
      end
    end
  end
end
