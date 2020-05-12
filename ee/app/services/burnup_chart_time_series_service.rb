# frozen_string_literal: true

class BurnupChartTimeSeriesService
  include Gitlab::Utils::StrongMemoize

  EVENT_TYPE = 'event_type'.freeze
  CREATED_AT = 'created_at'.freeze
  MILESTONE_ID = 'value'.freeze
  WEIGHT = 'value'.freeze
  ACTION = 'action'.freeze
  ISSUE_ID = 'issue_id'.freeze
  STATE = 'value'.freeze

  def initialize(milestone:, user:)
    @user = user
    @milestone = milestone

    assign_dates_by_milestone
  end

  def execute
    return [] unless burnup_charts_available?

    time_series = []

    assigned_milestones = {}
    current_day = nil
    issue_weights = {}
    issue_count = 0
    current_date = nil

    resource_events.each do |event|
      event_date = Date.new(event.created_at)
      changed = false

      handle_added_milestone(event, assigned_milestones)

      if current_date.nil? || current_day.nil? || current_date != event_date
        current_date = event_date
        current_day = { date: event_date }
        time_series << current_day
      end

      # TODO: Refactor me.
      if weight_event?(event)
        issue_weights[event.issue_id] = event.weight
        changed = true
      else
        if milestone_event?(event)
          if add_milestone?(event) && event[:milestone_id] == milestone.id
            issue_count += 1
            changed = true
          elsif remove_milestone?(event)
            current_assigned_milestone_id = milestone_id_of(event, assigned_milestones)
            issue_count -= 1 if current_assigned_milestone_id == milestone.id
            issue_weights[event.issue_id] = 0
            changed = true
          end
        end
      end

      current_day[:weight] = sum_issue_weights(issue_weights)
      current_day[:issue_count] = issue_count

      time_series.pop unless changed

      handle_removed_milestone(event, assigned_milestones)
    end

    time_series
  end

  private

  attr_reader :milestone, :start_date, :due_date, :end_date, :user

  def burnup_charts_available?
    !milestone.burnup_charts_available? || !can_read_milestone?
  end

  def sum_issue_weights(weights)
    weights.sum { |_issue_id, weight| weight } # rubocop: disable CodeReuse/ActiveRecord
  end

  def can_read_milestone?
    Ability.allowed?(user, :read_milestone, milestone.parent)
  end

  def handle_added_milestone(event, assigned_milestones)
    if add_milestone?(event)
      assigned_milestones[event[ISSUE_ID]] = event[MILESTONE_ID]
    end
  end

  def handle_removed_milestone(event, assigned_milestones)
    if remove_milestone?(event)
      assigned_milestones[event[ISSUE_ID]] = nil
    end
  end

  def resource_events
    strong_memoize(:resource_events) do
      union = Gitlab::SQL::Union.new(all_events).to_sql # rubocop: disable Gitlab/Union
      ActiveRecord::Base.connection.execute("(#{union}) ORDER BY created_at")
    end
  end

  def all_events
    [milestone_events, weight_events, state_events]
  end

  def weight_events
    ResourceWeightEvent.by_issue_ids_and_created_at_earlier_or_equal_to(relevant_issue_ids, end_time)
      .select('\'weight\' as event_type, created_at, weight as value, null as action, issue_id')
  end

  def milestone_events
    ResourceMilestoneEvent.by_issue_ids_and_created_at_earlier_or_equal_to(relevant_issue_ids, end_time)
      .select('\'milestone\' as event_type, created_at, milestone_id as value, action, issue_id')
  end

  def state_events
    ResourceStateEvent.by_issue_ids_and_created_at_earlier_or_equal_to(relevant_issue_ids, end_time)
      .select('\'state\' as event_type, created_at, state as value, null as action, issue_id')
  end

  def create_burnup_graph_event_by(event, assigned_milestones)
    {
      event_type: event[EVENT_TYPE],
      created_at: event[CREATED_AT],
      action: action_of(event),
      milestone_id: milestone_id_of(event, assigned_milestones),
      issue_id: event[ISSUE_ID],
      weight: weight_of(event),
      state: state_of(event)
    }
  end

  def state_of(event)
    return unless state_event?(event)

    ResourceStateEvent.states.key(event[STATE])
  end

  def action_of(event)
    return unless milestone_event?(event)

    ResourceMilestoneEvent.actions.key(event[ACTION])
  end

  def weight_of(event)
    return unless weight_event?(event)

    event[WEIGHT]
  end

  def assign_dates_by_milestone
    @start_date = milestone.start_date
    @due_date = milestone.due_date
    @end_date = if due_date.blank? || due_date > Date.today
                  Date.today
                else
                  due_date
                end
  end

  def milestone_id_of(event, assigned_milestones)
    return unless milestone_event?(event)

    if remove_milestone?(event) && event[MILESTONE_ID].nil?
      return assigned_milestones[event[ISSUE_ID]]
    end

    event[MILESTONE_ID]
  end

  def add_milestone?(event)
    return unless milestone_event?(event)

    event[ACTION] == ResourceMilestoneEvent.actions[:add]
  end

  def remove_milestone?(event)
    return unless milestone_event?(event)

    event[ACTION] == ResourceMilestoneEvent.actions[:remove]
  end

  def weight_event?(event)
    event[EVENT_TYPE] == 'weight'
  end

  def milestone_event?(event)
    event[EVENT_TYPE] == 'milestone'
  end

  def state_event?(event)
    event[EVENT_TYPE] == 'state'
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def relevant_issue_ids
    # We are using all resource milestone events where the
    # milestone in question was added to identify the relevant
    # issues.
    strong_memoize(:relevant_issue_ids) do
      ResourceMilestoneEvent
        .select(:issue_id)
        .where(milestone_id: milestone.id)
        .where(action: :add)
        .distinct
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end

  def end_time
    @end_time ||= @end_date.end_of_day
  end
end
