# frozen_string_literal: true

module Sprints
  class DestroyService < Sprints::BaseService
    def execute(sprint)
      Sprint.transaction do
        update_params = { sprint: nil, skip_timebox_email: true }

        sprint.issues.each do |issue|
          Issues::UpdateService.new(parent, current_user, update_params).execute(issue)
        end

        sprint.merge_requests.each do |merge_request|
          MergeRequests::UpdateService.new(parent, current_user, update_params).execute(merge_request)
        end

        log_destroy_event_for(sprint)

        sprint.destroy
      end
    end

    def log_destroy_event_for(sprint)
      return if sprint.group_timebox?

      event_service.destroy_sprint(sprint, current_user)

      Event.for_sprint_id(sprint.id).each do |event|
        event.target_id = nil
        event.save
      end
    end
  end
end
