# frozen_string_literal: true

module Types
  module Ci
    class GroupType < BaseObject
      graphql_name 'Group'

      field :name, GraphQL::STRING_TYPE, null: true,
        description: 'Name of the group'
      field :size, GraphQL::INT_TYPE, null: true,
        description: 'Size of the group'
      field :jobs, JobType, null: true,
        description: 'Jobs'
    end
  end
end
