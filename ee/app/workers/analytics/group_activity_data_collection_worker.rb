# frozen_string_literal: true

class GroupActivityDataCollectionWorker
  include ApplicationWorker

  idempotent!

  # rubocop:disable CodeReuse/ActiveRecord
  def perform(group_id)
    @group_id = group_id
    issues
  end

  private

  def issues
    # Take all projects from the given group and it's sub-groups
    # find all issues created in those projects
    #
    puts Issue.where(group: @group_id, created_at: Date.yesterday..Date.today).count.to_sql
  end
end
