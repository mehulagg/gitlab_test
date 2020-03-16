# frozen_string_literal: true

module QA
  module Support
    module Api
      HTTP_STATUS_OK = 200
      HTTP_STATUS_CREATED = 201
      HTTP_STATUS_NO_CONTENT = 204
      HTTP_STATUS_ACCEPTED = 202

      def post(url, payload)
        #   RestClient::Request.execute(
        #     method: :post,
        #     url: url,
        #     payload: payload,
        #     verify_ssl: false)
        # rescue RestClient::ExceptionWithResponse => e
        #   return_response_or_raise(e)
        puts ">>>>>>>>> POST '#{url}&#{payload}'"
        `curl --socks5-hostname 127.0.0.1:1080 --location --request POST '#{url}&#{payload}' --header 'Content-Type: application/json'`
      end

      def get(url, raw_response: false)
        RestClient::Request.execute(
          method: :get,
          url: url,
          verify_ssl: false,
          raw_response: raw_response)
      rescue RestClient::ExceptionWithResponse => e
        return_response_or_raise(e)
      end

      def put(url, payload)
        #   RestClient::Request.execute(
        #     method: :put,
        #     url: url,
        #     payload: payload,
        #     verify_ssl: false)
        # rescue RestClient::ExceptionWithResponse => e
        #   return_response_or_raise(e)
        puts ">>>>>>>>> PUT '#{url}&#{payload}'"
        `curl --socks5-hostname 127.0.0.1:1080 --location --request PUT '#{url}&#{payload}' --header 'Content-Type: application/json'`
      end

      def delete(url)
        RestClient::Request.execute(
          method: :delete,
          url: url,
          verify_ssl: false)
      rescue RestClient::ExceptionWithResponse => e
        return_response_or_raise(e)
      end

      def head(url)
        RestClient::Request.execute(
          method: :head,
          url: url,
          verify_ssl: false)
      rescue RestClient::ExceptionWithResponse => e
        return_response_or_raise(e)
      end

      def parse_body(response)
        JSON.parse(response.body, symbolize_names: true)
      end

      def return_response_or_raise(error)
        raise error unless error.respond_to?(:response) && error.response

        error.response
      end
    end
  end
end

# data = {path: "shl_test_group1", name: "shl_test_group1",visibility: "public"}
#
# `curl --socks5-hostname 127.0.0.1:1080 --location --request POST 'https://migration-test.githost.io/api/v4/groups?private_token=HrhkN5RUbBwkfp6ftBEF&name=gitlab-qa-perf-sandbox-baaade9fa61c3afe&path=gitlab-qa-perf-sandbox-baaade9fa61c3afe&visibility=public' --header 'Content-Type: application/json'`
#
#
# `curl --socks5-hostname 127.0.0.1:1080 --location --request GET 'https://migration-test.githost.io/api/v4/groups?private_token=HrhkN5RUbBwkfp6ftBEF' --header 'Private-Token: swAcuWQFr9yv2rHxnkpT'`
#
#
