# frozen_string_literal: true

module EE
  module Types
    module ProjectType
      extend ActiveSupport::Concern

      prepended do
        field :service_desk_enabled, GraphQL::BOOLEAN_TYPE, null: true,
          description: 'Indicates if the project has service desk enabled.'

        field :service_desk_address, GraphQL::STRING_TYPE, null: true,
          description: 'E-mail address of the service desk.'

        field :dependencies, [::Types::Security::DependencyType], null: true,
          description: 'Components used by the project',
          resolver: ::Resolvers::Security::DependencyResolver
          # authorize: :read_dependencies

        field :licenses, [::Types::Security::LicenseType], null: true,
              description: 'Licenses used by the project',
              resolver: ::Resolvers::Security::LicenseResolver
      end
    end
  end
end
