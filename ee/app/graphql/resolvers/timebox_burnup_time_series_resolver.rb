# frozen_string_literal: true

module Resolvers
  class TimeboxBurnupTimeSeriesResolver < BaseResolver
    type [Types::BurnupChartDailyTotalsType], null: true

    alias_method :timebox, :synchronized_object

    def resolve(*args)
      return [] unless timebox.burnup_charts_available?

      response = TimeboxBurnupChartService.new(timebox).execute

      raise GraphQL::ExecutionError, response.message if response.error?

      response.payload
    end
  end
end
