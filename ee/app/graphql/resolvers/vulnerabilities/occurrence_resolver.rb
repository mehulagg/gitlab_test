# frozen_string_literal: true

module Resolvers
  module Vulnerabilities
    class OccurrenceResolver < BaseResolver

      type Types::Vulnerabilities::OccurrenceType, null: true

      def resolve(**args)
        Vulnerabilities::Occurrence.all
      end
    end
  end
end
