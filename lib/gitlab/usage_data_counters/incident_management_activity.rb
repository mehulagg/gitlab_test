# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    # Allows for tracking and reporting events in lib/gitlab/usage_data_counters/known_events.yml
    # in the incident_management category.
    class IncidentManagementActivity
      EVENT_CATEGORY  = 'incident_management'

      class << self
        def track_event(user, identifier)
          return unless Feature.enabled?(:"track_#{identifier}", default_enabled: true)

          Gitlab::UsageDataCounters::HLLRedisCounter.track_event(user.id, identifier.to_s)
        end

        # returns [Integer] count of unique users to
        # interact with incident management space
        def total_unique_users(start_date:, end_date:)
          Gitlab::UsageDataCounters::HLLRedisCounter.unique_events(
            event_names: incident_management_events,
            start_date: start_date,
            end_date: end_date
          )
        end

        # returns [Hash<Symbol, Integer>] representing count
        # of unique users to perform individual actions
        def unique_users_by_action(start_date:, end_date:)
          incident_management_events.map do |event|
            [
              action_for_event(event),
              Gitlab::UsageDataCounters::HLLRedisCounter.unique_events(
                event_names: event,
                start_date: start_date,
                end_date: end_date
              )
            ]
          end.to_h
        end

        private

        def incident_management_events
          Gitlab::UsageDataCounters::HLLRedisCounter.events_for_category(EVENT_CATEGORY)
        end

        def action_for_event(event)
          event.delete_prefix('incident_management_').to_sym
        end
      end
    end
  end
end
