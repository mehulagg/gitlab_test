# frozen_string_literal: true

module API
  module Validations
    module Types
      class CommaSeparatedToArray
        def self.coerce
          lambda do |value|
            case value
            when String
              value.split(',').map(&:strip)
            when Array
              value.flat_map { |v| v.to_s.split(',').map(&:strip) }
            else
              []
            end
          end
        end
      end
    end
  end
end
