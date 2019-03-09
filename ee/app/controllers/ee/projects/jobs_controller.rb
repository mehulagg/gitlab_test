# frozen_string_literal: true

module EE
  module Projects
    module JobsController
      extend ActiveSupport::Concern

      prepended do
        before_action :authorize_create_proxy_build!, only: [:proxy_authorize, :proxy_websocket_authorize]
        before_action :verify_proxy_request!, only: [:proxy_authorize, :proxy_websocket_authorize]
      end

      def proxy_authorize
        render json: ::Gitlab::Workhorse.service_request(build_service_specification)
      end

      def proxy_websocket_authorize
        render json: proxy_websocket_service(build_service_specification)
      end

      private

      def authorize_create_proxy_build!
        return access_denied! unless can?(current_user, :create_proxy_build, build)
      end

      def verify_proxy_request!
        ::Gitlab::Workhorse.verify_api_request!(request.headers)
        set_workhorse_internal_api_content_type
      end

      def proxy_websocket_service(service)
        service[:url] = service[:url]&.sub('https://', 'wss://')

        ::Gitlab::Workhorse.channel_websocket(service)
      end

      def build_service_specification
        subprotocol = request.headers['HTTP_SEC_WEBSOCKET_PROTOCOL']

        build.service_specification(service: params['service'],
                                    port: params['port'],
                                    requested_url: params['requested_uri'],
                                    subprotocols: subprotocol)
      end
    end
  end
end
