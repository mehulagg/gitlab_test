# frozen_string_literal: true

class GroupActivityDataCollectionWorker
  include ApplicationWorker

  idempotent!

  def perform(group_id)
    @group_id = group_id
    active_users
  end

  private

  def active_users
    GroupActiveUsersFinder.new(group_id, 90.days.ago).execute.count
  end
end
