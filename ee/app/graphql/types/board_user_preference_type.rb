# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class BoardUserPreferenceType < BaseObject
    graphql_name 'BoardUserPreference'
    description 'Board preferences for users.'

    field :hide_labels, GraphQL::BOOLEAN_TYPE, null: true, description: 'Whether or not labels are hidden on board lists.'
  end
  # rubocop: enable Graphql/AuthorizeTypes
end
