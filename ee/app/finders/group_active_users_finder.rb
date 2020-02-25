# frozen_string_literal: true

class GroupActiveUsersFinder
  # include Gitlab::Allowable
  OFFSET_INCREMENT = 100

  def initialize(group, oldest_created_at: 90.days.ago)
    @group = group
    @active_users = []
    @event_filter = EventFilter.new(nil)
  end

  def execute
    offset = 0

    loop do
      events = EventCollection.new(projects: projects, limit: offset_increment, offset: offset, filter: @event_filter, groups: groups).to_a
      break if events.empty?

      result = events.each do |event|
        break if event.created_at < oldest_created_at

        @active_users << event.author_id
      end

      break if result.nil?
    end

    store_active_users
  end

  private

  # rubocop: disable CodeReuse/ActiveRecord
  def groups
    return @groups if @groups

    # TODO Fix query
    @groups = Group.where(parent: @group)
    @groups << @group
    @groups
  end

  def projects
    # TODO Fix query
    Project.where(namespace: groups)
  end
  # rubocop: enable CodeReuse/ActiveRecord

  # TODO
  def store_active_users
    puts "Total #{@active_users.uniq.count} active users"
  end
end
