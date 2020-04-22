# frozen_string_literal: true

module Types
  class ReleaseLinkType < BaseObject
    graphql_name 'ReleaseLink'

    authorize :read_release

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'The ID of the link'
    field :name, GraphQL::STRING_TYPE, null: true,
          description: 'The name of the link'
    field :url, GraphQL::STRING_TYPE, null: true,
          description: 'The URL of the link'

    field :external, GraphQL::BOOLEAN_TYPE, null: true, method: :external?,
          description: 'Whether or not the link points to an external resource'
  end
end
