# frozen_string_literal: true

module Resolvers
  module Security
    class LicenseResolver < BaseResolver
      type [Types::Security::LicenseType], null: true

      def resolve(**args)
        ::SCA::LicenseCompliance.new(object).policies
      end
    end
  end
end
