# frozen_string_literal: true

class Burnup
  include Gitlab::Utils::StrongMemoize

  attr_reader :milestone, :start_date, :due_date, :end_date, :user

  def initialize(milestone:, user:, start_date: nil, end_date: nil)
    @user = user
    @milestone = milestone

    if valid_time_frame?(start_date, end_date)
      @start_date, @end_date = start_date, end_date
    else
      assign_dates_by_milestone
    end
  end

  def burnup_events
    resource_milestone_events.map do |event|
      {
          created_at: event.created_at,
          event_type: event_type_of(event),
          action: event.action,
          milestone_id: milestone_id_of(event),
          issue_id: issue_id_of(event)
      }
    end
  end

  private

  def assign_dates_by_milestone
    @start_date = milestone.start_date
    @due_date = milestone.due_date
    @end_date = if due_date.blank? || due_date > Date.today
                  Date.today
                else
                  due_date
                end
  end

  def valid_time_frame?(start_date, end_date)
    start_date.present? && end_date.present? &&
      start_date.beginning_of_day.before?(end_date.end_of_day)
  end

  def event_type_of(event)
    return 'milestone' if event.is_a?(ResourceMilestoneEvent)

    'event'
  end

  def milestone_id_of(event)
    return unless event.is_a?(ResourceMilestoneEvent)

    event.milestone_id
  end

  def issue_id_of(event)
    return event.target_id unless event.is_a?(ResourceMilestoneEvent)

    event.issue_id
  end

  def resource_milestone_events
    # Here we use the relevant issues to get *all* milestone events for
    # them.

    strong_memoize(:resource_milestone_events) do
      ResourceMilestoneEvent
          .where(issue_id: relevant_issue_ids)
          .where(created_at: start_time..end_time)
          .order(:created_at)
    end
  end

  def relevant_issue_ids
    # We are using all resource milestone events where the
    # milestone in question was added to identify the relevant
    # issues.

    strong_memoize(:relevant_issue_ids) do
      ids = ResourceMilestoneEvent
          .select(:issue_id)
          .where(milestone_id: milestone.id)
          .where(action: :add)
          .distinct

      # We need to perform an additional check whether all these issues are visible to the given user
      IssuesFinder.new(user)
          .execute.preload(:assignees).select(:id).where(id: ids)
    end
  end

  def start_time
    @start_time ||= @start_date.beginning_of_day.to_time
  end

  def end_time
    @end_time ||= @end_date.end_of_day.to_time
  end
end
