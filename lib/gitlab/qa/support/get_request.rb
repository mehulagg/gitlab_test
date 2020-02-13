require 'net/http'
require 'uri'

module Gitlab
  module QA
    module Support
      class GetRequest
        attr_reader :uri, :token

        def initialize(uri, token)
          @uri = uri
          @token = token
        end

        def execute!
          response =
            Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
              http.request(build_request)
            end

          case response
          when Net::HTTPSuccess
            response
          else
            raise Support::InvalidResponseError.new(uri.to_s, response)
          end
        end

        private

        def build_request
          Net::HTTP::Get.new(uri).tap do |req|
            req['PRIVATE-TOKEN'] = token
            req['Cookie'] = ENV['QA_COOKIES'] if ENV['QA_COOKIES']
          end
        end
      end
    end
  end
end
