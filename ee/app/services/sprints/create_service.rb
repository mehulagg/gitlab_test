# frozen_string_literal: true

module Sprints
  class CreateService < Sprints::BaseService
    def execute
      sprint = parent.sprints.new(params)

      if sprint.save && sprint.project_timebox?
        event_service.open_sprint(sprint, current_user)
      end

      sprint
    end
  end
end
