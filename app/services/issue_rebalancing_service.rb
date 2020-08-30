# frozen_string_literal: true

class IssueRebalancingService
  MAX_ISSUE_COUNT = 10_000
  TooManyIssues = Class.new(StandardError)

  def initialize(issue, update_batch_size = 100, in_transaction = true)
    @issue = issue
    @base = Issue.relative_positioning_query_base(issue)
    @update_batch_size = update_batch_size
    @in_transaction = in_transaction
  end

  def execute
    gates = [issue.project, issue.project.group].compact
    return unless gates.any? { |gate| Feature.enabled?(:rebalance_issues, gate) }

    raise TooManyIssues, "#{issue_count} issues" if issue_count > MAX_ISSUE_COUNT

    start = RelativePositioning::START_POSITION - (gaps / 2) * gap_size

    Issue.connection.exec_query(<<~SQL, 'Create new-positions temporary table')
      create temp table #{temp_table_name} as
      select id as issue_id, relative_position as new_pos
      from issues
      limit 0
    SQL

    created_table = true

    indexed_ids.each_slice(500) do |pairs|
      insert_pairs(start, pairs)
    end

    ranges = indexed_ids.each_slice(update_batch_size).map do |pairs|
      (pairs.first.first..pairs.last.first)
    end

    if @in_transaction
      Issue.connection.transaction { update_ranges(ranges) }
    else
      update_ranges(ranges)
    end

  ensure
    Issue.connection.exec_query("drop table #{temp_table_name}") if created_table
  end

  private

  attr_reader :issue, :base, :update_batch_size

  def update_ranges(ranges)
    ranges.each do |range|
      Issue.connection.exec_query(<<~SQL, 'update issue positions')
        update issues
        set relative_position = new_pos
        from #{temp_table_name}
        where id = issue_id AND id between #{range.first} and #{range.last}
      SQL
    end
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def indexed_ids
    base.reorder(:relative_position, :id).pluck(:id).each_with_index
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def insert_pairs(start, positions)
    values = positions.map do |id, index|
      "(#{id}, #{start + (index * gap_size)})"
    end.join(', ')

    Issue.connection.exec_query(<<~SQL, 'Insert pairs')
      insert into #{temp_table_name} values #{values}
    SQL
  end

  def temp_table_name
    'temp_issue_position_updates'
  end

  def issue_count
    @issue_count ||= base.count
  end

  def gaps
    issue_count - 1
  end

  def gap_size
    # We could try to split the available range over the number of gaps we need,
    # but IDEAL_DISTANCE * MAX_ISSUE_COUNT is only 0.1% of the available range,
    # so we are guaranteed not to exhaust it by using this static value.
    #
    # If we raise MAX_ISSUE_COUNT or IDEAL_DISTANCE significantly, this may
    # change!
    RelativePositioning::IDEAL_DISTANCE
  end
end
