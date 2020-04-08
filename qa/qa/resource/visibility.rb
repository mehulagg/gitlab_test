# frozen_string_literal: true

module QA
  module Resource
    module Visibility
      def set_visibility(visibility = VisibilityLevel::PUBLIC)
        put Runtime::API::Request.new(api_client, api_visibility_path).url, { visibility: visibility }
      end

      class VisibilityLevel
        [:public, :internal, :private].map do |level|
          const_set(level.upcase, level)
        end
      end
    end
  end
end
