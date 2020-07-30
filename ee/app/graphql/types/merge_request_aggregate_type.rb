# frozen_string_literal: true

module Types
  class MergeRequestAggregateType < BaseObject
    graphql_name 'MergeRequestAggregate'
    description 'Represents an iteration object.'

    # authorize :read_iteration

    field :count, GraphQL::ID_TYPE, null: false,
          description: 'number of records'
  end
end

