# frozen_string_literal: true

module Gitlab
  module Graphql
    module Connections
      def self.use(schema)
        GraphQL::Relay::BaseConnection.register_connection_implementation(
          ActiveRecord::Relation,
          Gitlab::Graphql::Connections::Keyset::Connection
        )

        GraphQL::Relay::BaseConnection.register_connection_implementation(
          Gitlab::Graphql::ExternallyPaginatedArray,
          Gitlab::Graphql::Connections::ExternallyPaginatedArrayConnection
        )

        schema.connections.add(
          Gitlab::Graphql::FilterableArray,
          Gitlab::Graphql::Pagination::FilterableArrayConnection)
      end
    end
  end
end
