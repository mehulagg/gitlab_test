# frozen_string_literal: true

require 'securerandom'

module QA
  module Runtime
    module Search
      extend self
      extend Support::Api

      ElasticSearchServerError = Class.new(RuntimeError)

      def elasticsearch_responding?
        QA::Runtime::Logger.debug("Attempting to search via Elasticsearch...")

        search_term = SecureRandom.hex(8)
        content = "Elasticsearch test commit #{search_term}"
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.commit_message = content
          commit.add_files(
            [
              {
                file_path: 'test.txt',
                content: content
              }
            ]
          )
        end

        QA::Support::Retrier.retry_on_exception(max_attempts: 6, sleep_interval: 10) do
          request = Runtime::API::Request.new(api_client, "/search?scope=commits&search=#{search_term}")
          response = get(request.url)

          unless response.code == singleton_class::HTTP_STATUS_OK
            raise ElasticSearchServerError, "Search attempt failed. Request returned (#{response.code}): `#{response}`."
          end

          true
        end
      end

      private

      def api_client
        @api_client ||= Runtime::API::Client.new(:gitlab)
      end
    end
  end
end
