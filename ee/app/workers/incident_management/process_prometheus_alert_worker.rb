# frozen_string_literal: true

module IncidentManagement
  class ProcessPrometheusAlertWorker
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
        issue = create_issue(project, alert_hash)&.dig(:issue)
        relate_issue_to_event(event, issue) if issue
      end
    end

    private

    def find_prometheus_alert_event(group_key)
      PrometheusAlertEvent.find_by_payload_key(group_key)
    end

    def link_issues(project, event, alert_hash)
      issue = last_related_issue(event)

      # TODO: Different behavior if this was closed automatically
      # vs manually. https://gitlab.com/gitlab-org/gitlab-ee/issues/13401
      if issue.closed?
        related_issues = event.related_issues
        # YES, and closed - create & link
        new_issue = create_issue(project, alert_hash)&.dig(:issue)
        if new_issue
          relate_issue_to_event(event, new_issue)
          relate_issues(new_issue, related_issues)
        end
      else
        # Open, create system note (or comment?)
        create_system_note(issue, alert_hash)
      end
    end

    def relate_issue_to_event(event, issue)
      if !event.related_issues.include?(issue)
        event.related_issues << issue
      end
    end

    def relate_issues(issue, related_issues)
      issue_params = { issuable_references: related_issues.map(&:to_reference) }
      IssueLinks::CreateService.new(issue, User.alert_bot, issue_params).execute
    end

    def create_system_note(issue, alert_hash)
      # TODO: Find proper data for this
      SystemNoteService.relate_prometheus_alert_issue(
        issue,
        issue.project,
        User.alert_bot,
        alert_start_time(alert_hash),
        'somewhere in the code'
      )
    end

    def alert_start_time(alert_hash)
      alert_hash.dig('startsAt')
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
