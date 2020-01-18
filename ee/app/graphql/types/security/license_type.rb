# frozen_string_literal: true

module Types
  module Security
    class LicenseType < BaseObject
      graphql_name 'License'

      # authorize :read_licenses

      field :name, GraphQL::STRING_TYPE, null: true,
            description: 'Name of a license'

      field :url, GraphQL::STRING_TYPE, null: true,
            description: 'Path of a license'

      field :dependencies, ::Types::Security::DependencyType, null: true
    end
  end
end
