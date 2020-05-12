# frozen_string_literal: true

class AuthorizedProjectsWorker
  include ApplicationWorker
  prepend WaitableWorker

  feature_category :authentication_and_authorization
  urgency :high
  weight 2
  idempotent!
  loggable_arguments 1 # For the job waiter key

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(user_id)
    user = User.find_by(id: user_id)

    user&.refresh_authorized_projects
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
