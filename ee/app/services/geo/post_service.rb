# frozen_string_literal: true

module Geo
  class PostService
    private

    def execute_post(url, body)
      response = Gitlab::HTTP.post(url, body: body, allow_local_requests: true, headers: headers, timeout: timeout)

      unless response.success?
        handle_failure_for(response)
        return false
      end

      true
    rescue Gitlab::HTTP::Error, Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
      log_error('Failed to post to primary', e)
      false
    end

    def handle_failure_for(response)
      message = "Could not connect to Geo primary node - HTTP Status Code: #{response.code} #{response.message}"
      payload = response.parsed_response
      details =
        if payload.is_a?(Hash)
          payload['message']
        else
          # The return value can be a giant blob of HTML; ignore it
          ''
        end

      log_error([message, details].compact.join("\n"))
    end

    def primary_node
      Gitlab::Geo.primary_node || raise(Gitlab::Geo::GeoNodeNotFoundError.new('Failed to look up Geo primary node in the database'))
    end

    def headers
      Gitlab::Geo::BaseRequest.new(scope: ::Gitlab::Geo::API_SCOPE).headers
    end

    def timeout
      Gitlab::CurrentSettings.geo_status_timeout
    end
  end
end
