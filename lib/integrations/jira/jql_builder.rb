# frozen_string_literal: true

module Integrations
  module Jira
    class JqlBuilder
      DEFAULT_SORT = "created"
      DEFAULT_SORT_DIRECTION = "DESC"

      attr_reader :jql

      def initialize(jira_project_key, params = {})
        @jira_project_key = jira_project_key
        @search = params[:search]
        @labels = params[:labels]
        @sort = params[:sort] || DEFAULT_SORT
        @sort_direction = params[:sort_direction] || DEFAULT_SORT_DIRECTION

        @jql = build_jql
      end

      private

      attr_reader :jira_project_key, :sort, :sort_direction, :search, :labels, :reporter, :assignee

      def build_jql
        [
          jql_filters,
          order_by
        ].join(' ')
      end

      def jql_filters
        [
          by_project,
          by_labels,
          by_summary_and_description
        ].compact.join(" AND ")
      end

      def by_summary_and_description
        return if search.blank?

        "(summary ~ '#{search}' OR description ~ '#{search}')"
      end

      def by_project
        "project = #{jira_project_key}"
      end

      def by_labels
        return if labels.blank?

        labels.map { |label| "labels = '#{label}'" }.join(" AND ")
      end

      def order_by
        "order by #{sort} #{sort_direction}"
      end
    end
  end
end
