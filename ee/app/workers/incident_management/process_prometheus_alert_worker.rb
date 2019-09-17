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
        create_issue(project, alert_hash)
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
        issue_result = create_issue(project, alert_hash)
        relate_issues(issue_result[:issue], related_issues) if issue_result[:issue]
      else
        # Open, create system note (or comment?)
        create_system_note(issue)
      end
    end

    def relate_issues(issue, related_issues)
      issue_params = { issuable_references: related_issues.map(&:to_reference) }
      IssueLinks::CreateService.new(issue, User.alert_bot, issue_params).execute
    end

    def create_system_note(issue)
      # TODO: Find proper data for this
      SystemNoteService.relate_prometheus_alert_issue(
        issue,
        issue.project,
        User.alert_bot,
        Time.now,
        'somewhere in the code'
      )
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
