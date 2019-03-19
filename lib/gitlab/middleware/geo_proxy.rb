# frozen_string_literal: true

module Gitlab
  module Middleware
    class GeoProxy < Rack::Proxy
      def perform_request(env)
        request = Rack::Request.new(env)
        if write_action?(request) && Gitlab::Geo.secondary?
          primary_http_host = Gitlab::Geo.primary_node.uri.host
          primary_http_host += ":#{Gitlab::Geo.primary_node.uri.port}" unless on_standard_port?(Gitlab::Geo.primary_node.uri.port)

          Rails.logger.info "[GeoProxy] perform_request: Replacing #{env["HTTP_HOST"]} with #{primary_http_host}"
          env["HTTP_HOST"] = primary_http_host

          env['content-length'] = nil

          super(env)
        else
          @app.call(env)
        end
      end

      def rewrite_response(triplet)
        status, headers, body = triplet
        location = headers["location"]
        location = location.first if location.is_a?(Array)

        if location.present? && rewritable_location?(location)
          primary_http_host = Gitlab::Geo.primary_node.uri.host
          primary_http_host += ":#{Gitlab::Geo.primary_node.uri.port}" unless on_standard_port?(Gitlab::Geo.primary_node.uri.port)
          this_http_host = Settings.gitlab.url.sub(%r{.*://}, '')

          Rails.logger.info "[GeoProxy] rewrite_response: Replacing #{primary_http_host} with #{this_http_host} in #{location}"
          headers["location"] = location.sub(primary_http_host, this_http_host)
        end

        # if you proxy depending on the backend, it appears that content-length isn't calculated correctly
        # resulting in only partial responses being sent to users
        # you can remove it or recalculate it here
        headers["content-length"] = nil

        triplet
      end

      def write_action?(request)
        %w{post patch put delete}.include?(request.request_method.downcase)
      end

      def on_standard_port?(port)
        ["80", "443"].include?(port)
      end

      def rewritable_location?(location)
        valid_locations = %w{
          /users/sign_in
          /oauth/authorize
          /oauth/geo/logout
        }

        valid_locations.none? { |v| location.match(v) }
      end
    end
  end
end
