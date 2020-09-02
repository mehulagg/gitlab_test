# frozen_string_literal: true

module Gitlab
  class ContributionsCalendar
    include Gitlab::Utils::StrongMemoize

    attr_reader :contributor
    attr_reader :current_user
    attr_reader :projects

    def initialize(contributor, current_user = nil)
      @contributor = contributor
      @current_user = current_user
      @projects = if @contributor.include_private_contributions?
                    ContributedProjectsFinder.new(@contributor).execute(@contributor)
                  else
                    ContributedProjectsFinder.new(contributor).execute(current_user)
                  end
    end

    def activity_dates
      strong_memoize(:activity_dates) do
        activity_dates_query.group('date') # rubocop: disable CodeReuse/ActiveRecord
          .select('date as key, sum(total_amount)::int as value')
          .to_h { |record| [record.key, record.value] }
      end
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def events_by_date(date)
      return Event.none unless can_read_cross_project?

      Event.contributions.where(author_id: contributor.id)
        .where(created_at: date.beginning_of_day..date.end_of_day)
        .where(project_id: projects)
        .with_associations
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def starting_year
      1.year.ago.year
    end

    def starting_month
      Date.current.month
    end

    private

    # rubocop: disable CodeReuse/ActiveRecord
    def activity_dates_query
      # Can't use Event.contributions here because we need to check different
      # project_features

      join_on_notes = %q{
        INNER JOIN notes ON target_type = 'Note' AND target_id = notes.id
      }

      queries = [
        event_counts(:repository).having(action: :pushed),
        event_counts(:issues).having(action: %i[created closed], target_type: 'Issue'),
        event_counts(:wiki).having(action: %i[created updated], target_type: 'WikiPage::Meta'),
        event_counts(:merge_requests).having(action: %i[merged created closed], target_type: 'MergeRequest'),
        event_counts(:issues).having(action: %i[created updated], target_type: 'DesignManagement::Design'),
        event_counts(:merge_requests, 'notes.noteable_type')
          .joins(join_on_notes)
          .having('action = ? AND notes.noteable_type = ?', Event.actions[:commented], 'MergeRequest'),
        event_counts(nil, 'notes.noteable_type')
          .joins(join_on_notes)
          .having('action = ? AND notes.noteable_type != ?', Event.actions[:commented], 'MergeRequest')
      ]

      Event.with(user_events_in_range.to_arel).from_union(queries, remove_duplicates: false)
    end

    # rubocop: enable CodeReuse/ActiveRecord
    def can_read_cross_project?
      Ability.allowed?(current_user, :read_cross_project)
    end

    def contributed_project_ids
      # re-running the contributed projects query in each union is expensive, so
      # use IN(project_ids...) instead. It's the intersection of two users so
      # the list will be (relatively) short
      strong_memoize(:contributed_project_ids) { projects.distinct.pluck(:id) } # rubocop: disable CodeReuse/ActiveRecord
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def user_events_in_range
      strong_memoize(:my_events_this_year) do
        date_from = 1.year.ago
        t = Event.arel_table
        conditions = t[:created_at].gteq(date_from.beginning_of_day)
          .and(t[:created_at].lteq(Date.current.end_of_day))
          .and(t[:author_id].eq(contributor.id))

        date_interval = "INTERVAL '#{Time.zone.now.utc_offset} seconds'"

        q = Event.reorder(nil)
          .select(:id, :project_id, :target_type, :target_id, :action, "date(events.created_at + #{date_interval}) as date")
          .where(conditions)

        Gitlab::SQL::CTE.new(:user_events_in_range, q)
      end
    end

    def total_amount
      Event.arel_table[:id].count.as('total_amount')
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def event_counts(feature, *grouping_columns)
      t = Event.arel_table
      authed_projects = if feature
                          Project.where(id: contributed_project_ids)
                            .with_feature_available_for_user(feature, current_user)
                            .reorder(nil)
                        else
                          contributed_project_ids
                        end

      Event.from(user_events_in_range.alias_to(Event.arel_table))
        .where(project_id: authed_projects) # rubocop:disable GitlabSecurity/SqlInjection
        .group(t[:project_id], :target_type, :action, :date, *grouping_columns)
        .select(t[:project_id], :target_type, :action, :date, total_amount)
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
