# frozen_string_literal: true

module Types
  class DastSiteProfileType < BaseObject
    graphql_name 'DastSiteProfile'
    description 'Represents a DAST Site Profile.'

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'ID of the site profile'

    field :profile_name, GraphQL::STRING_TYPE, null: false,
          description: 'The name of the site profile',
          resolve: -> (obj, _args, _ctx) { obj.name }

    field :target_url, GraphQL::STRING_TYPE, null: false,
          description: 'The URL of the target to be scanned',
          resolve: -> (obj, _args, _ctx) { obj.dast_site.url }

    field :validation_status, GraphQL::STRING_TYPE, null: false,
          description: 'The current validation status of the site profile',
          resolve: -> (_obj, _args, _ctx) { :PENDING_VALIDATION }
  end
end
