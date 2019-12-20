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
        commit = Resource::Repository::Commit.fabricate_via_api! do |commit|
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

        QA::Support::Retrier.retry_until(max_attempts: 3, sleep_interval: 10) do
          QA::Support::Retrier.retry_on_exception(max_attempts: 3, sleep_interval: 10) do
            found_commit?(commit, "commit*#{search_term}") && found_project?(project, "to-search*#{search_term}1")
          end
        end
      end

      def find_commits(search_term)
        search('commits', search_term)
      end

      def find_projects(search_term)
        search('projects', search_term)
      end

      def found_commit?(commit, search_term)
        result = find_commits(search_term)
        return false unless result && result.any? { |c| c[:message] == commit.commit_message }

        QA::Runtime::Logger.debug("Found commit '#{commit.commit_message} (#{commit.short_id})' via '#{search_term}'")
        true
      end

      def found_project?(project, search_term)
        result = find_projects(search_term)
        return false unless result && result.any? { |p| p[:name] == project.name }

        QA::Runtime::Logger.debug("Found project '#{project.name}' via '#{search_term}'")
        true
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

        parse_body(response)
      end

      def api_client
        @api_client ||= Runtime::API::Client.new(:gitlab)
      end
    end
  end
end
