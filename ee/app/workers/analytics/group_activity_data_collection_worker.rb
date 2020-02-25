# frozen_string_literal: true

class GroupActivityDataCollectionWorker
  include ApplicationWorker

  idempotent!

  # rubocop:disable CodeReuse/ActiveRecord
  def perform(group_id)
    Issue.where(group: group_id, created_at: Date.yesterday..Date.today).count.to_sql
  end
end
