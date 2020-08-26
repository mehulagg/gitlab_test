# frozen_string_literal: true

module Gitlab
  module Analytics
    module IncidentManagement
      class AlertStatusChangeEvent < Base
        def self.name
          s_("IncidentManagementEvent|Alert status changed")
        end

        def self.identifier
          :incident_management_alert_status_changed
        end
      end
    end
  end
end
