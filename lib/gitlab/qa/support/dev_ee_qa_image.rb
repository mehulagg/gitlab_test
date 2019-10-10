require 'json'
require 'uri'

module Gitlab
  module QA
    module Support
      class DevEEQAImage
        attr_reader :base_url

        DEV_ADDRESS = 'https://dev.gitlab.org'.freeze
        GITLAB_EE_QA_REPOSITORY_ID = 55
        QAImageNotFoundError = Class.new(StandardError)

        def initialize
          @base_url = "#{DEV_ADDRESS}/api/v4/projects/gitlab%2Fomnibus-gitlab/registry/repositories/#{GITLAB_EE_QA_REPOSITORY_ID}/tags?per_page=100"

          Runtime::Env.require_qa_dev_access_token!
        end

        def retrieve_image_from_container_registry!(revision)
          request_url = base_url

          begin
            response = api_get!(URI.parse(request_url))
            tags = JSON.parse(response.body)

            matching_qa_image_tag = find_matching_qa_image_tag(tags, revision)
            return matching_qa_image_tag['location'] if matching_qa_image_tag

            request_url = next_page_url_from_response(response)
          end while request_url

          raise QAImageNotFoundError, "No `gitlab-ee-qa` image could be found for the revision `#{revision}`."
        end

        private

        def api_get!(uri)
          Support::GetRequest.new(uri, Runtime::Env.qa_dev_access_token).execute!
        end

        def next_page_url_from_response(response)
          response['x-next-page'].to_s != '' ? "#{base_url}&page=#{response['x-next-page']}" : nil
        end

        def find_matching_qa_image_tag(tags, revision)
          tags.find { |tag| tag['name'].end_with?(revision) }
        end
      end
    end
  end
end
