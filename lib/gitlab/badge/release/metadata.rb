# frozen_string_literal: true

module Gitlab
  module Badge
    module Release
      class Metadata < Badge::Metadata
        def initialize(badge)
          @project = badge.project
          @ref = badge.ref
        end

        def title
          'latest release'
        end

        def image_url
          release_project_badges_url(@project, @ref, format: :svg)
        end

        def link_url
          project_release_url(@project, id: @ref)
        end
      end
    end
  end
end
