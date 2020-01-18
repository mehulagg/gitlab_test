# frozen_string_literal: true

module Types
  module Security
    class DependencyType < BaseObject
      graphql_name 'Dependency'

      # mount on project

      field :name, GraphQL::STRING_TYPE, null: true,
            description: 'Name of a dependency'

      field :version, GraphQL::STRING_TYPE, null: true,
            description: 'Version of a dependency'

      field :packager, GraphQL::STRING_TYPE, null: true,
            description: 'Package manager of a dependency'

      field :location, GraphQL::STRING_TYPE, null: true,
            description: 'Location of a dependency in a project'

      field :licenses, [::Types::Security::LicenseType], null: true,
            description: 'Licenses associated with a dependency',
            resolve: -> (dependency, _, _) do
              dependency[:licenses]
            end

      field :vulnerabilities, [::Types::Security::VulnerabilityType], null: true,
            description: 'Vulnerabilities associated with a dependency',
            resolve: -> (dependency, _args, _ctx) do
              dependency[:vulnerabilities]
            end
    end
  end
end
