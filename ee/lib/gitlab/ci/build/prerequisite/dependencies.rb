# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Prerequisite
        class Dependencies < Base
          def unmet?
            !dependencies.cached?
          end

          def complete!
            return unless unmet?

            dependencies.cross_pipeline
          end

          def dependencies
            strong_memoize(:dependencies) do
              ::Ci::Processable::Dependencies.new(build)
            end
          end
        end
      end
    end
  end
end
