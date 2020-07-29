# frozen_string_literal: true

module Gitlab
  module Issues
    class IssueTypeCounts
      include Gitlab::Utils::StrongMemoize

      ISUEE_TYPES = ::Issue.issue_types

      attr_reader :project

      def self.declarative_policy_class
        'IssuePolicy'
      end

      def initialize(current_user, project, params)
        @project = project
        @current_user = current_user
        @params = params
      end

      # Define method for each issue type
      ISUEE_TYPES.each_key do |issue_type|
        define_method(issue_type) { counts[issue_type] }
      end

      def all
        counts.values.sum # rubocop:disable CodeReuse/ActiveRecord
      end

      private

      attr_reader :current_user, :params

      def counts
        strong_memoize(:counts) do
          Hash.new(0).merge(counts_by_issue_type)
        end
      end

      def counts_by_issue_type
        ::IssuesFinder
          .counts_by_issue_type(current_user, project, params)
      end
    end
  end
end
