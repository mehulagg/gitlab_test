# frozen_string_literal: true

module Gitlab
  module GroupActivityAnalytics
    class DataCollector
      EVENT_TYPES = %i[issues_created].freeze

      attr_reader :group

      def initialize(group)
        @group = group
      end

      def data
        {
          group_issues_count: group_issues_count,
          group_merge_requests_count: group_merge_requests_count
        }
      end

      private

      def group_issues_count
        IssuesFinder.new(
          current_user,
          group_id: @group.id,
          state: 'all',
          non_archived: true,
          include_subgroups: true,
          created_at: "> #{90.days.ago}"
        ).execute
          .count
      end

      def group_merge_requests_count
        MergeRequestsFinder.new(
          current_user,
          group_id: @group.id,
          state: 'all',
          non_archived: true,
          include_subgroups: true,
          created_at: "> #{90.days.ago}"
        ).execute
          .count
      end
    end
  end
end
