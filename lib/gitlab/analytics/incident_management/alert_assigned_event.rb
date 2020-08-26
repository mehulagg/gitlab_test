# frozen_string_literal: true

module Gitlab
  module Analytics
    module IncidentManagement
      class AlertAssignedEvent < Base
        def self.name
          s_("IncidentManagementEvent|Alert assigned")
        end

        def self.identifier
          :incident_management_alert_assigned
        end
      end
    end
  end
end
