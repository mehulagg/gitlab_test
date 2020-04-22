# frozen_string_literal: true

module Types
  class ReleaseSourceType < BaseObject
    graphql_name 'ReleaseSource'

    authorize [:read_release, :reporter_access]

    field :format, GraphQL::STRING_TYPE, null: true,
          description: 'The format of the source'
    field :url, GraphQL::STRING_TYPE, null: true,
          description: 'The URL that can be used to download the source'
  end
end
