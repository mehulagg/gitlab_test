# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Build
        module Prerequisite
          module Factory
            extend ::Gitlab::Utils::Override

            override :prerequisites
            def self.prerequisites
              super + [Gitlab::Ci::Build::Prerequisite::Dependencies]
            end
          end
        end
      end
    end
  end
end
