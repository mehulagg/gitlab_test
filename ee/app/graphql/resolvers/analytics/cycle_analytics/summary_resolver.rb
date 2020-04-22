# frozen_string_literal: true

module Resolvers
  module Analytics
    module CycleAnalytics
      class SummaryResolver < BaseResolver
        include Gitlab::Graphql::Authorize::AuthorizeResource

        argument :created_after, Types::TimeType,
                  required: true,
                  description: 'Issues created after this date'
        argument :created_before, Types::TimeType,
                  required: true,
                  description: 'Issues created before this date'

        def resolve(created_after:, created_before:)
          summary = ::Gitlab::CycleAnalytics::GroupStageSummary.new(group, options: {
            current_user: context[:current_user],
            from: created_after,
            to: created_before
          })

          {
            new_issue_count: summary.issue_summary,
            deployment_count: summary.deployments_summary,
            deployment_frequency: summary.deployment_frequency_summary
          }
        end

        def authorize!
          Ability.allowed?(context[:current_user], :read_group_cycle_analytics, object) || raise_resource_not_available_error!
        end

        def group
          object
        end
      end
    end
  end
end
