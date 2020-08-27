# frozen_string_literal: true

module API
  module Validations
    module Validators
      class ArrayNoneAny < Grape::Validations::Base
        def validate_param!(attr_name, params)
          value = params[attr_name]

          return if value.is_a?(Array) ||
              [IssuableFinderParams::FILTER_NONE, IssuableFinderParams::FILTER_ANY].include?(value.to_s.downcase)

          raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)],
                                               message: "should be an array, 'None' or 'Any'"
        end
      end
    end
  end
end
