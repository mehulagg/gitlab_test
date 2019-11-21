# frozen_string_literal: true

module Types
  module Vulnerabilities
    # rubocop: disable Graphql/AuthorizeTypes
    class OccurrenceType < BaseObject
      graphql_name 'VulnerabilityOccurrence'

      field :severity, GraphQL::STRING_TYPE, null: false,
            description: 'Severity of the vulnerability'

      field :confidence, GraphQL::STRING_TYPE, null: false,
            description: 'Confidence of the vulnerability'

      field :name, GraphQL::STRING_TYPE, null: false,
            description: 'Name of the vulnerability'
    end
  end
end