# frozen_string_literal: true

module EE
  module Ci
    # Build EE mixin
    #
    # This module is intended to encapsulate EE-specific model logic
    # and be included in the `Build` model
    module BuildRunnerSession
      extend ActiveSupport::Concern

      def service_specification(service: nil, requested_url: '', port:)
        return {} unless url.present?

        port = port.presence || Gitlab::Ci::Build::Port::DEFAULT_PORT_NAME
        service = service.presence || Gitlab::Ci::Build::Port::DEFAULT_SERVICE_NAME

        url = "#{self.url}/proxy/#{service}/#{port}/#{requested_url}"
        channel_specification(url, ::Ci::BuildRunnerSession::TERMINAL_SUBPROTOCOL)
      end
    end
  end
end
