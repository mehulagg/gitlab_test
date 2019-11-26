# frozen_string_literal: true

module Resolvers
  module Vulnerabilities
    class OccurrenceResolver < BaseResolver
      argument :id, GraphQL::ID_TYPE, required: true,
               description: 'bla bla bla'

      type Types::Vulnerabilities::OccurrenceType, null: true

      def resolve(**args)
        ::Vulnerabilities::Occurrence.find(args[:id])
      end
    end
  end
end
