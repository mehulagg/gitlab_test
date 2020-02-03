# frozen_string_literal: true

module Gitlab
  module Badge
    module Release
      class Latest_Release < Badge::Base
        attr_reader :project, :ref

        def initialize(project, ref)
          @project = project
          @ref = ref
        end

        def entity
          'latest release'
        end

        def status
          @release = @project.releases.last.tag || 'none'
        end

        def metadata
          @metadata ||= Release::Metadata.new(self)
        end

        def template
          @template ||= Release::Template.new(self)
        end
      end
    end
  end
end
