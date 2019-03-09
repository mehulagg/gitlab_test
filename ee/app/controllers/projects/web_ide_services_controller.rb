# # frozen_string_literal: true

# class Projects::WebIdeServicesController < Projects::ApplicationController
#   before_action :authenticate_user!
#   before_action :build
#   before_action :authorize_update_web_ide_terminal!
#   before_action :verify_api_request!, only: [:proxy_authorize, :proxy_websocket_authorize]
#   before_action :set_workhorse_internal_api_content_type, only: [:proxy_authorize, :proxy_websocket_authorize]

#   def proxy_authorize
#     render json: Gitlab::Workhorse.service_request(build_service_specification)
#   end

#   def proxy_websocket_authorize
#     render json: webide_websocket_service(build_service_specification)
#   end

#   private

#   def authorize_update_web_ide_terminal!
#     return access_denied! unless can?(current_user, :update_web_ide_terminal, build)
#   end

#   def build
#     @build ||= project.builds.find(params[:id])
#   end

#   def webide_websocket_service(service)
#     service[:url] = service[:url]&.sub('https://', 'wss://')

#     Gitlab::Workhorse.channel_websocket(service)
#   end

#   def build_service_specification
#     subprotocol = request.headers['HTTP_SEC_WEBSOCKET_PROTOCOL']

#     build.service_specification(service: params['service'],
#                                 port: params['port'],
#                                 requested_url: params['requested_uri'],
#                                 subprotocols: subprotocol)
#   end

#   def verify_api_request!
#     Gitlab::Workhorse.verify_api_request!(request.headers)
#   end
# end
