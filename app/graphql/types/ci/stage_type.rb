# frozen_string_literal: true

module Types
  module Ci
    class StageType < BaseObject
      graphql_name 'Stage'

      field :name, GraphQL::STRING_TYPE, null: true,
        description: 'Name of the stage'
      field :groups, [Ci::GroupType], null: true,
        description: 'Groups'
    end
  end
end
