require 'net/http'
require 'json'
require 'uri'

module Gitlab
  module QA
    module Component
      class Staging
        ADDRESS = 'https://staging.gitlab.com'.freeze
        GEO_SECONDARY_ADDRESS = 'https://geo.staging.gitlab.com'.freeze

        def self.release
          Release.new(image)
        rescue Support::InvalidResponseError => ex
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
            #
            # For official builds (currently deployed on preprod) we use the version
            # string e.g. '12.5.4-ee' for tag matching
            Support::DevEEQAImage.new.retrieve_image_from_container_registry!(tag_end)
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

        def self.tag_end
          @tag_end ||= Version.new(address).tag_end
        end

        class Version
          attr_reader :uri

          def initialize(address)
            @uri = URI.join(address, '/api/v4/version')

            Runtime::Env.require_qa_access_token!
          end

          def tag_end
            official? ? version : revision
          end

          def major_minor_revision
            api_response = api_get!
            version_regexp = /^v?(?<major>\d+)\.(?<minor>\d+)\.\d+/
            match = version_regexp.match(api_response.fetch('version'))

            "#{match[:major]}.#{match[:minor]}-#{api_response.fetch('revision')}"
          end

          private

          def official?
            Release::DEV_OFFICIAL_TAG_REGEX.match?(version)
          end

          def revision
            api_get!.fetch('revision')
          end

          def version
            api_get!.fetch('version')
          end

          def api_get!
            @response_body ||= # rubocop:disable Naming/MemoizedInstanceVariableName
              begin
                response = Support::GetRequest.new(uri, Runtime::Env.qa_access_token).execute!
                JSON.parse(response.body)
              end
          end
        end
      end
    end
  end
end
