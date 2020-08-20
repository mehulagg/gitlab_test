# frozen_string_literal: true

require "graphql/client"
require "graphql/client/http"

module Gitlab::ImportExport::V2::Project
  module Graphql
    HTTP = ::GraphQL::Client::HTTP.new('http://localhost:3000/api/graphql')

    Schema = ::GraphQL::Client.load_schema(HTTP)

    Client = ::GraphQL::Client.new(schema: Schema, execute: HTTP)
  end
end
