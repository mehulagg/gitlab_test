module Gitlab
  module QA
    class Release
      CANONICAL_REGEX = /
        \A
          (?<edition>ce|ee)
          (-qa)?
          (:(?<tag>.+))?
        \z
      /xi
      CUSTOM_GITLAB_IMAGE_REGEX = %r{
        \A
          (?<image_without_tag>
            (?<registry>[^\/:]+(:(?<port>\d+))?)
            .+
            gitlab-
            (?<edition>ce|ee)
          )
          (-qa)?
          (:(?<tag>.+))?
        \z
      }xi

      # Official dev tag example:
      #  12.5.4(-rc42)-ee
      # |-------------|--|
      #   |             |
      #   |             |
      #   |             |
      #   |          edition
      # version
      DEV_OFFICIAL_TAG_REGEX = /
        \A
          (?<version>\d+\.\d+.\d+(?:-rc\d+)?)-(?<edition>ce|ee)
        \z
      /xi

      # Dev tag example:
      #  12.1.201906121026-325a6632895.b340d0bd35d
      # |----|------------|-----------|-----------|
      #   |         |           |           |
      #   |         |           |      omnibus-ref
      #   |         |       gitlab-ee ref
      #   |     timestamp
      # version
      DEV_TAG_REGEX = /
        \A
          (?<version>\d+\.\d+(.\d+)?)\.(?<timestamp>\d+)\-(?<gitlab_ref>[A-Za-z0-9]+)\.(?<omnibus_ref>[A-Za-z0-9]+)
        \z
      /xi

      DEFAULT_TAG = 'latest'.freeze
      DEFAULT_CANONICAL_TAG = 'nightly'.freeze
      DEV_REGISTRY = 'dev.gitlab.org:5005'.freeze

      InvalidImageNameError = Class.new(RuntimeError)

      attr_reader :release
      attr_writer :tag

      def initialize(release)
        @release = release.to_s.downcase

        raise InvalidImageNameError, "The release image name '#{@release}' does not have the expected format." unless valid?
      end

      def to_s
        "#{image}:#{tag}"
      end

      def previous_stable
        # The previous stable is always gitlab/gitlab-ce:latest or
        # gitlab/gitlab-ee:latest
        self.class.new("#{canonical_image}:latest")
      end

      def edition
        @edition ||=
          if canonical?
            release.match(CANONICAL_REGEX)[:edition].to_sym
          else
            release.match(CUSTOM_GITLAB_IMAGE_REGEX)[:edition].to_sym
          end
      end

      def ee?
        edition == :ee
      end

      def to_ee
        return self if ee?

        self.class.new(to_s.sub('ce:', 'ee:'))
      end

      def image
        @image ||=
          if canonical?
            "gitlab/gitlab-#{edition}"
          else
            release.match(CUSTOM_GITLAB_IMAGE_REGEX)[:image_without_tag]
          end
      end

      def qa_image
        "#{image}-qa"
      end

      def project_name
        @project_name ||=
          if canonical?
            "gitlab-#{edition}"
          else
            "gitlab-#{release.match(CUSTOM_GITLAB_IMAGE_REGEX)[:edition]}"
          end
      end

      # Tag scheme for gitlab-{ce,ee} images is like 11.1.0-rc12.ee.0
      def tag
        @tag ||=
          if canonical?
            release.match(CANONICAL_REGEX)[:tag] || DEFAULT_CANONICAL_TAG
          else
            release.match(CUSTOM_GITLAB_IMAGE_REGEX)&.[](:tag) || DEFAULT_TAG
          end
      end

      # Tag scheme for gitlab-{ce,ee}-qa images is like 11.1.0-rc12-ee
      def qa_tag
        if dev_gitlab_org? && (match_data = tag.match(DEV_TAG_REGEX))
          "#{match_data[:version]}-#{match_data[:gitlab_ref]}"
        else
          tag.sub(/[-\.]([ce]e)(\.(\d+))?\z/, '-\1')
        end
      end

      def dev_gitlab_org?
        image.start_with?(DEV_REGISTRY)
      end

      def valid?
        canonical? || release.match?(CUSTOM_GITLAB_IMAGE_REGEX)
      end

      private

      def canonical?
        release =~ CANONICAL_REGEX
      end

      def canonical_image
        @canonical_image ||= "gitlab/gitlab-#{edition}"
      end
    end
  end
end
