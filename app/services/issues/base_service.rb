# frozen_string_literal: true

module Issues
  class BaseService < ::IssuableBaseService
    def hook_data(issue, action, old_associations: {})
      hook_data = issue.to_hook_data(current_user, old_associations: old_associations)
      hook_data[:object_attributes][:action] = action

      hook_data
    end

    def reopen_service
      Issues::ReopenService
    end

    def close_service
      Issues::CloseService
    end

    private

    NO_REBALANCING_NEEDED = ((RelativePositioning::MIN_POSITION * 0.9999)..(RelativePositioning::MAX_POSITION * 0.9999)).freeze

    def rebalance_if_needed(issue)
      return unless issue
      return if issue.relative_position.nil?
      return if NO_REBALANCING_NEEDED.cover?(issue.relative_position)

      gates = [issue.project, issue.project.group].compact
      return unless gates.any? { |gate| Feature.enabled?(:rebalance_issues, gate) }

      IssueRebalancingWorker.perform_async(nil, issue.project_id)
    end

    def create_assignee_note(issue, old_assignees)
      SystemNoteService.change_issuable_assignees(
        issue, issue.project, current_user, old_assignees)
    end

    def execute_hooks(issue, action = 'open', old_associations: {})
      issue_data  = hook_data(issue, action, old_associations: old_associations)
      hooks_scope = issue.confidential? ? :confidential_issue_hooks : :issue_hooks
      issue.project.execute_hooks(issue_data, hooks_scope)
      issue.project.execute_services(issue_data, hooks_scope)
    end

    def update_project_counter_caches?(issue)
      super || issue.confidential_changed?
    end

    def delete_milestone_closed_issue_counter_cache(milestone)
      return unless milestone

      Milestones::ClosedIssuesCountService.new(milestone).delete_cache
    end

    def delete_milestone_total_issue_counter_cache(milestone)
      return unless milestone

      Milestones::IssuesCountService.new(milestone).delete_cache
    end

    def track_incident_action(issue, user, action)
      return unless issue.issue_type == 'incident'

      ::Gitlab::UsageDataCounters::IncidentManagementActivity.track_event(user, :"incident_management_#{action}")
    end
  end
end

Issues::BaseService.prepend_if_ee('EE::Issues::BaseService')
