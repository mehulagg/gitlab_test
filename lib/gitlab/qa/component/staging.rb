require 'net/http'
require 'json'
require 'uri'

module Gitlab
  module QA
    module Component
      class Staging
        ADDRESS = 'https://staging.gitlab.com'.freeze

        class InvalidResponseError < StandardError
          attr_reader :response

          def initialize(address, response)
            @response = response

            super "Invalid response received from #{address}"
          end
        end

        def self.release
          Release.new(image)
        rescue InvalidResponseError => ex
          warn ex.message
          warn "#{ex.response.code} #{ex.response.message}: #{ex.response.body}"
          exit 1
        end

        def self.image
          if Runtime::Env.dev_access_token_variable
            # Auto-deploy builds have a tag formatted like 12.1.12345+5159f2949cb.59c9fa631
            # where `5159f2949cb` is the EE commit SHA. QA images are tagged using
            # the version from the VERSION file and this commit SHA, e.g.
            # `12.0-5159f2949cb` (note that the `major.minor` doesn't necessarily match).
            # To work around that, we're fetching the `revision` from the version API
            # and then find the corresponding QA image in the
            # `dev.gitlab.org:5005/gitlab/omnibus-gitlab/gitlab-ee-qa` container
            # registry, based on this revision.
            # See:
            #  - https://gitlab.com/gitlab-org/quality/staging/issues/56
            #  - https://gitlab.com/gitlab-org/release/framework/issues/421
            #  - https://gitlab.com/gitlab-org/gitlab-qa/issues/398
            DevEEQAImage.new.retrieve_image_from_container_registry!(staging_revision)
          else
            # Auto-deploy builds have a tag formatted like 12.0.12345+5159f2949cb.59c9fa631
            # but the version api returns a semver version like 12.0.1
            # so images are tagged using minor and major semver components plus
            # the EE commit ref, which is the 'revision' returned by the API
            # and so the version used for the docker image tag is like 12.0-5159f2949cb
            # See: https://gitlab.com/gitlab-org/quality/staging/issues/56
            "ee:#{Version.new(address).major_minor_revision}"
          end
        end

        def self.address
          self::ADDRESS
        end

        def self.staging_revision
          @staging_revision ||= Version.new(address).revision
        end

        class Version
          attr_reader :uri

          def initialize(address)
            @uri = URI.join(address, '/api/v4/version')

            Runtime::Env.require_qa_access_token!
          end

          def revision
            api_get!.fetch('revision')
          end

          def major_minor_revision
            api_response = api_get!
            version_regexp = /^v?(?<major>\d+)\.(?<minor>\d+)\.\d+/
            match = version_regexp.match(api_response.fetch('version'))

            "#{match[:major]}.#{match[:minor]}-#{api_response.fetch('revision')}"
          end

          private

          def api_get!
            @response_body ||=
              begin
                response = GetRequest.new(uri, Runtime::Env.qa_access_token).execute!
                JSON.parse(response.body)
              end
          end
        end

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
            GetRequest.new(uri, Runtime::Env.qa_dev_access_token).execute!
          end

          def next_page_url_from_response(response)
            response['x-next-page'].to_s != '' ? "#{base_url}&page=#{response['x-next-page']}" : nil
          end

          def find_matching_qa_image_tag(tags, revision)
            tags.find { |tag| tag['name'].end_with?(revision) }
          end
        end

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
              raise InvalidResponseError.new(uri.to_s, response)
            end
          end

          private

          def build_request
            Net::HTTP::Get.new(uri).tap do |req|
              req['PRIVATE-TOKEN'] = token
            end
          end
        end
      end
    end
  end
end
