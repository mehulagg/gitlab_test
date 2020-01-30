# frozen_string_literal: true

module Gitlab
  class PollingInterval
    HEADER_NAME = 'Poll-Interval'

    def self.set_header(response_or_headers, interval:)
      if polling_enabled?
        multiplier = Gitlab::CurrentSettings.polling_interval_multiplier
        value = (interval * multiplier).to_i
      else
        value = -1
      end

      if response_or_headers.respond_to?(:headers)
        response_or_headers.headers[HEADER_NAME] = value.to_s
      else
        response_or_headers[HEADER_NAME] = value.to_s
      end
    end

    def self.polling_enabled?
      !Gitlab::CurrentSettings.polling_interval_multiplier.zero?
    end
  end
end
