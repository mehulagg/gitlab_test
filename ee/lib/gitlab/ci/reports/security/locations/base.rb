# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Locations
          class Base
            attr_reader :fingerprint

            def ==(other)
              other.fingerprint == fingerprint
            end

            private

            def generate_fingerprint
              raise NotImplementedError
            end
          end
        end
      end
    end
  end
end
