# frozen_string_literal: true

module Gitlab
  module JiraImport
    class BaseImporter
      ITEMS_PER_PAGE = 1000
      attr_reader :project, :import_data

      def initialize(project)
        @jira_project_key = project.import_data.data.dig("jira", "jira_project_key")

        unless @jira_project_key.present?
          raise Projects::ImportService::Error, "Unable to find jira project to import data from."
        end

        @project = project
        @formatter = Gitlab::ImportFormatter.new
        @client = project.jira_service.client
      end

      def execute
        import

        project.after_import
      end

      private

      def import
        start_at = 0

        while start_at % ITEMS_PER_PAGE == 0
          issues = fetch_issues(start_at)
          import_issues(issues)
          start_at += issues.size
        end
      end

      def fetch_issues(start_at)
        @client.Issue.jql("PROJECT='#{@jira_project_key}' ORDER BY created ASC", {
          fields: %w(summary description status reporter assignee updated created comment labels),
          max_results: ITEMS_PER_PAGE, start_at: start_at
        })
      end

      def import_issues(issues)
        issues.each do |jira_issue|
          body = [@formatter.author_line(jira_issue.reporter.displayName)]
          body << @formatter.assignee_line(jira_issue.assignee.displayName) if jira_issue.assignee
          body << jira_issue.description # todo: GFM parsing

          summary = "[#{jira_issue.key}] #{jira_issue.summary}"
          gitlab_issue = project.issues.create!(
            # iid: jira_issue.key.scan(/d+/), #todo: handle iid mapping ?
            description: body.join,
            title: summary,
            state: get_status(jira_issue.status.statusCategory),
            updated_at: jira_issue.updated,
            created_at: jira_issue.created,
            author_id: project.creator_id # todo: map actual author
          )

          import_comments(gitlab_issue, jira_issue)
        end
      end

      def import_comments(gitlab_issue, jira_issue)
        jira_issue.comments.each do |comment|
          next unless comment.body.present?

          note = ''
          note += @formatter.author_line(comment.author['displayName'])
          note += comment.body # todo: GFM parsing

          gitlab_issue.notes.create!(
            project: project,
            note: note,
            author_id: project.creator_id, # todo: map actual author
            created_at: comment.created,
            updated_at: comment.updated
          )
        end
      end

      def get_status(jira_status_category)
        case jira_status_category["key"].downcase
        when 'done'
          :closed
        else
          :opened
        end
      end
    end
  end
end
