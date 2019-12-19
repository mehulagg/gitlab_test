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
        project = Resource::Project.fabricate_via_api! do |project|
          project.name = "project-to-search-#{search_term}1"
        end
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
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
          search('commits', "commit*#{search_term}") && search('projects', "to-search*#{search_term}1")
        end
      end

      private

      def search(scope, term)
        QA::Runtime::Logger.debug("Search scope '#{scope}' for '#{term}'...")
        request = Runtime::API::Request.new(api_client, "/search?scope=#{scope}&search=#{term}")
        response = get(request.url)

        unless response.code == singleton_class::HTTP_STATUS_OK
          msg = "Search attempt failed. Request returned (#{response.code}): `#{response}`."
          QA::Runtime::Logger.debug(msg)
          raise ElasticSearchServerError, msg
        end

        QA::Runtime::Logger.debug("Found '#{term}'...")
        true
      end

      def api_client
        @api_client ||= Runtime::API::Client.new(:gitlab)
      end
    end
  end
end
