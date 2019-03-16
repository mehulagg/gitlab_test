# frozen_string_literal: true

class QuickActionScheduleWorker
  include ApplicationWorker


  # rubocop: disable CodeReuse/ActiveRecord
  def perform(project_id, user_id, action, issuable_id)
    project = Project.find(project_id)
    user = User.find(user_id)
    issuabe = Issuable.find(issuable_id)
    QuickActions::InterpretService.new(project, user).execute(action, issuable)
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
