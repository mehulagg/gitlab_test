# frozen_string_literal: true

module EE
  module Projects
    module JobsController
      include ::Gitlab::Utils::StrongMemoize
      extend ActiveSupport::Concern

      # In Seconds
      TOKEN_EXPIRATION_TIME = 60

      prepended do
        # before_action :authorize_create_proxy_build!, only: [:proxy, :proxy_websocket_authorize]
        before_action :verify_proxy_request!, only: [:proxy_websocket_authorize]
      end

      def proxy_websocket_authorize
        render json: proxy_websocket_service(build_service_specification)
      end

      def proxy
        return access_denied! if ::Feature.disabled?(:build_service_http_proxy)
        return respond_422 unless params[:service].present?

        url = proxy_url
        if url.present?
          redirect_to url
        else
          respond_422
        end
      end

      private

      def authorize_create_proxy_build!
        return access_denied! unless can?(current_user, :create_build_service_proxy, build)
      end

      def verify_proxy_request!
        ::Gitlab::Workhorse.verify_api_request!(request.headers)
        set_workhorse_internal_api_content_type
      end

      # This method provides the information to Workhorse
      # about the service we want to proxy to.
      # For security reasons, in case this operation is started by JS,
      # it's important to use only sourced GitLab JS code
      def proxy_websocket_service(service)
        service[:url] = ::Gitlab::UrlHelpers.as_wss(service[:url])

        ::Gitlab::Workhorse.channel_websocket(service)
      end

      def build_service_specification
        build.service_specification(service: params['service'],
                                    port: params['port'],
                                    path: params['path'],
                                    subprotocols: proxy_subprotocol)
      end

      def proxy_subprotocol
        # This will allow to reuse the same subprotocol set
        # in the original websocket connection
        request.headers['HTTP_SEC_WEBSOCKET_PROTOCOL'].presence || ::Ci::BuildRunnerSession::TERMINAL_SUBPROTOCOL
      end

      def proxy_url
        content_url = ::Gitlab.config.workhorse.user_content_url
        return if content_url.blank?

        URI.parse(content_url).tap do |u|
          ## Given the transient nature of the jobs, 32 chars seem enough
          u.host = [SecureRandom.hex, u.host].join('.')
          u.query = proxy_params.merge(build: build.id, token: proxy_token(u.host, u.port)).to_query
        end.to_s
      rescue URI::InvalidURIError
        nil
      end

      def proxy_params
        params.permit(:service, :port)
      end

      def proxy_token(domain, port)
        ::JSONWebToken::HMACToken.new(::Gitlab::Workhorse.secret).tap do |token|
          token[:job_id] = build.id.to_s
          token[:token] = "bla" # FIXME TODO
          token[:domain] = [domain, port].join(':')
          token[:exp] = Time.now.to_i + TOKEN_EXPIRATION_TIME
        end.encoded
      end
    end
  end
end
