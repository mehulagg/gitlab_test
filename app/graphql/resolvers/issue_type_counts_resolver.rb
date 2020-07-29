# frozen_string_literal: true

module Resolvers
  class IssueTypeCountsResolver < BaseResolver
    type Types::IssueTypeCountsType, null: true


    # TODO accept all arguments for issues??


    # argument :search, GraphQL::STRING_TYPE,
    #           description: 'Search criteria for filtering alerts. This will search on title, description, service, monitoring_tool.',
    #           required: false

    def resolve(**args)
      ::Gitlab::Issues::IssueTypeCounts.new(context[:current_user], object, args)
    end
  end
end
