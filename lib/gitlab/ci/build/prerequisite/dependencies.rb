# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Prerequisite
        class Dependencies < Base
          def unmet?
            !build.cached_dependencies?
          end

          def complete!
            return unless unmet?

            build.resolve_and_cache_dependencies!
            build.drop!(:missing_dependency_failure) unless build.has_valid_build_dependencies?
          end
        end
      end
    end
  end
end
