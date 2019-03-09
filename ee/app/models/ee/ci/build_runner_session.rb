# frozen_string_literal: true

module EE
  module Ci
    # Build EE mixin
    #
    # This module is intended to encapsulate EE-specific model logic
    # and be included in the `Build` model
    module BuildRunnerSession
      extend ActiveSupport::Concern

      DEFAULT_SERVICE_NAME = 'build'.freeze

      def service_specification(service: nil, requested_url: '', port: nil, subprotocols: nil)
        return {} unless url.present?

        port = port.presence || ::Gitlab::Ci::Build::Port::DEFAULT_PORT_NAME
        service = service.presence || DEFAULT_SERVICE_NAME
        url = "#{self.url}/proxy/#{service}/#{port}/#{requested_url}"
        subprotocols = subprotocols.presence || ::Ci::BuildRunnerSession::TERMINAL_SUBPROTOCOL

        channel_specification(url, subprotocols)
      end
    end
  end
end
