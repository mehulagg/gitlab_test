# frozen_string_literal: true

module IncidentManagement
  class ProcessAlertWorker
    include ApplicationWorker

    queue_namespace :incident_management

    def perform(group_key, alert_hash)
      event = find_prometheus_alert_event(group_key)
      project = event&.project
      return unless project

      if event.related_issues.any?
        link_issues(project, event, alert_hash)
      else
        # If NO existing issues - create
        create_issue(project, alert_hash)
      end
    end

    private

    def find_prometheus_alert_event(group_key)
      PrometheusAlertEvent.find_by(group_key: group_key)
    end

    def link_issues(project, event, alert_hash)
      issue = last_related_issue(event)
      if issue.closed?
        # YES, and closed - create & link
        create_issue(project, alert_hash)
      else
        # YES, and open - system note
        # create_system_note
      end
    end

    def create_issue(project, alert_hash)
      IncidentManagement::CreateIssueService
        .new(project, alert_hash)
        .execute
    end

    def last_related_issue(event)
      event.last_related_issue
    end
  end
end
