# frozen_string_literal: true

module Types
  module Ci
    class JobType < BaseObject
      graphql_name 'Job'

      field :name, GraphQL::STRING_TYPE, null: true,
        description: 'Name of the job'
      field :needs, GraphQL::STRING_TYPE, null: true,
        description: 'Job needs'
    end
  end
end
