# frozen_string_literal: true

module Mutations
  module Vulnerabilities
    class Update < ::Mutations::BaseMutation
      graphql_name 'UpdateVulnerability'

      #why iid is used?
      # argument :id, GraphQL::STRING_TYPE,
      #          required: true,
      #          description: "The id of the vulnerability to mutate"

      # field :vulnerability,
      #       Types::Vulnerabilities::OccurrenceType,
      #       null: true,
      #       description: 'Vulnerability after mutation'
      #
      # #auth

      def resolve(args)
        "Hello world"
      end
    end
  end
end