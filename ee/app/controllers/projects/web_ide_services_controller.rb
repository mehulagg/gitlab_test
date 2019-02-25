# frozen_string_literal: true

class Projects::WebIdeServicesController < Projects::ApplicationController
  SERVICE_PORT = 8080.freeze

  before_action :authenticate_user!
  before_action :build
  before_action :authorize_update_web_ide_terminal!
  before_action :verify_api_request!, only: [:proxy_authorize, :proxy_websocket_authorize]

  # NOOP
  def proxy
  end

  def proxy_authorize
    set_workhorse_internal_api_content_type
    render json: webide_service(build_service_specification)
  end

  def proxy_websocket_authorize
    set_workhorse_internal_api_content_type
    render json: webide_websocket_service(build_service_specification)
  end

  private

  def authorize_update_web_ide_terminal!
    return access_denied! unless can?(current_user, :update_web_ide_terminal, build)
  end

  def build
    @build ||= project.builds.find(params[:id])
  end

  def webide_service(service)
    details = {
      'WebIdeService' => {
        'Url' => service[:url],
        'Header' => service[:headers]
      }
    }

    details['WebIdeService']['CAPem'] = service[:ca_pem] if service.key?(:ca_pem)

    details
  end

  def webide_websocket_service(service)
    webide_service(service).tap do |config|
      config['WebIdeService']['Subprotocol'] = service[:subprotocols]
      config['WebIdeService']['MaxSessionTime'] = 3000
      config['WebIdeService']['Url'] = config['WebIdeService'].fetch('Url', '').sub("https://", "wss://")
    end
  end

  def build_service_specification
    build.service_specification(service: params["service"], port: params["port"], requested_url: params["requested_uri"])
  end

  def verify_api_request!
    Gitlab::Workhorse.verify_api_request!(request.headers)
  end
end
