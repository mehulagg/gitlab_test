# frozen_string_literal: true

module Gitlab
  module WebIde
    class Config
      module Entry
        module Validators




          class ExternalPortUniqueValidator < PortUniqueValidator
            def initialize(options)
              super(options.merge(external: true))
            end
          end

          class InternalPortUniqueValidator < PortUniqueValidator
            def initialize(options)
              super(options.merge(external: false))
            end
          end
        end
      end
    end
  end
end
