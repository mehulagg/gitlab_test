# frozen_string_literal: true

module EE
  module Ci
    module BuildRunnerSession
      extend ActiveSupport::Concern

      DEFAULT_SERVICE_NAME = 'build'.freeze
      DEFAULT_PORT_NAME = 'default_port'.freeze

      def service_specification(service: nil, path: nil, port: nil, subprotocols: nil)
        return {} unless url.present?

        port = port.presence || DEFAULT_PORT_NAME
        service = service.presence || DEFAULT_SERVICE_NAME
        path = ERB::Util.url_encode(path.to_s.sub('/', ''))
        # url = URI.join("#{self.url}/proxy/#{service}/#{port}/", path).to_s
        puts "REAL URL #{URI.join("#{self.url}/proxy/#{service}/#{port}", path).to_s}"
        # FIXME DELETE JUST FOR TESTING
        url = URI.join("#{self.url}", path).to_s
        subprotocols = subprotocols.presence || ::Ci::BuildRunnerSession::TERMINAL_SUBPROTOCOL

        channel_specification(url, subprotocols)
      end
    end
  end
end
