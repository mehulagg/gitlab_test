# frozen_string_literal: true

module Gitlab
  module Analytics
    module IncidentManagement
      class Base
        BASE_EVENT_NAME = 'incident_management_activity'
        EVENT_CATEGORY  = 'incident_management'

        def self.track_event(user_id, time = Time.current)
          Gitlab::UsageDataCounters::HLLRedisCounter.track_event(user_id, identifier.to_s, time)
        end

        def self.all_incident_management_activity(start_date:, end_date:)
          events = Gitlab::UsageDataCounters::HLLRedisCounter.events_for_category(EVENT_CATEGORY)

          Gitlab::UsageDataCounters::HLLRedisCounter.unique_events(event_names: events, start_date: start_date, end_date: end_date)
        end
      end
    end
  end
end
