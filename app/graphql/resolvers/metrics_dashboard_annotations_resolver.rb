# frozen_string_literal: true

module Resolvers
  class MetricsDashboardAnnotationsResolver < BaseResolver
    #
    argument :search, GraphQL::STRING_TYPE,
              required: false,
              description: 'Search query'

    type Types::MetricsDashboardAnnotationType, null: true

    alias_method :metrics_dashboard, :object

    def resolve(**args)
      return unless metrics_dashboard.present?

      metrics_dashboard.annotations
    end
  end
end
