# frozen_string_literal: true

module Resolvers
  class MergeRequestAggregateResolver < BaseResolver
    type Types::MergeRequestAggregateType, null: true

    argument :merged_after, Types::TimeType,
      required: false,
      description: 'Issues created after this date'
    argument :merged_before, Types::TimeType,
      required: false,
      description: 'Issues created before this date'


    def resolve(**args)
      {
        count: rand(30)
      }
    end
  end
end

