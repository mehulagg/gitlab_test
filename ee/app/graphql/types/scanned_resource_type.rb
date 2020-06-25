# frozen_string_literal: true

module Types
    # rubocop: disable Graphql/AuthorizeTypes
    class ScannedResourceType < BaseObject
      graphql_name 'ScannedResource'
      description 'Represents a resource scanned by a security report'
  
      field :url, GraphQL::STRING_TYPE, null: true, description: 'the URL scanned by the scanner'
      field :request_method, GraphQL::STRING_TYPE, null: true, description: 'the request method'
    end
  end
  