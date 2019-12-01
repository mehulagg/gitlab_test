# frozen_string_literal: true

module Types
  module Security
    class DependencyType < BaseObject
      graphql_name 'Dependency'

      # authorize :read_dependencies

      field :name, GraphQL::STRING_TYPE, null: true,
            description: 'Name of a dependency'

      field :version, GraphQL::STRING_TYPE, null: true,
            description: 'Version of a dependency'

      field :packager, GraphQL::STRING_TYPE, null: true,
            description: 'Package manager of a dependency'

      field :location, GraphQL::STRING_TYPE, null: true,
            description: 'Location of a dependency in a project'

      # field :licenses, Types::Security::License.connection_type, null: true,
      #       description: 'Licenses associated with a dependency'

      # field :vulnerabilities Types::Security::Vulnerability.connection_type, null: true,
      #       description: 'Vulnerabilities associated with a dependency'
    end
  end
end
