# frozen_string_literal: true

module Gitlab
  module Badge
    module Release
      ##
      # Class that represents a release badge template.
      #
      # Template object will be passed to badge.svg.erb template.
      #
      class Template < Badge::Template
        STATUS_COLOR = {
          latest: '#3076af',
          none: '#e05d44'
        }.freeze

        def initialize(badge)
          @entity = badge.entity
          @status = badge.status
        end

        def key_text
          @entity.to_s
        end

        def value_text
          @status.to_s
        end

        def key_width
          62
        end

        def value_width
          54
        end

        def value_color
          STATUS_COLOR[@status.to_sym] || STATUS_COLOR[:latest]
        end
      end
    end
  end
end
