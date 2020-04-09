# frozen_string_literal: true

class Burnup
  include Gitlab::Utils::StrongMemoize

  attr_reader :milestone, :start_date, :due_date, :end_date, :visible_issue_ids

  def initialize(milestone, visible_issues:)
    @visible_issue_ids = visible_issues
    @milestone = milestone
    @start_date = milestone.start_date
    @due_date = milestone.due_date
    @end_date = if due_date.blank? || due_date > Date.today
                  Date.today
                else
                  due_date
                end
  end

  def burnup_data
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
          .order(:id) # alternative to ordering by created_at
    end
  end

  def relevant_issue_ids
    # We are using all resource milestone events where the
    # milestone in question was added to identify the relevant
    # issues.

    strong_memoize(:relevant_issue_ids) do
      ResourceMilestoneEvent
          .select(:issue_id)
          .where(milestone_id: milestone.id)
          .where(action: :add)
          .where(created_at: start_time..end_time)
          .where(issue_id: visible_issue_ids)
          .distinct
    end
  end

  def start_time
    @start_time ||= @start_date.beginning_of_day.to_time
  end

  def end_time
    @end_time ||= @end_date.end_of_day.to_time
  end
end
