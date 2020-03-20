# frozen_string_literal: true

module Resolvers
  class MetricsDashboardsResolver < BaseResolver
    argument :id, GraphQL::STRING_TYPE,
              required: false,
              description: 'Id of metrics dashboard'
    #
    # argument :search, GraphQL::STRING_TYPE,
    #           required: false,
    #           description: 'Search query'

    type Types::MetricsDashboardType, null: true

    def resolve(**args)
      [
        OpenStruct.new(
          to_global_id: 'gid://custom_dashboard.yml',
          id: 'custom_dashboard.yml',
          annotations: [ OpenStruct.new(to_global_id: 'gid://gitlab/Annotations/1', id: 1, description: 'annotation description', from: Time.now.to_s(:db), to: nil, panel_id: nil) ]
        )
      ]
    end
  end
end


