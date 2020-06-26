# frozen_string_literal: true

class Projects::JiraIssuesController < Projects::ApplicationController
  include IssuableCollections
  include RecordUserLastActivity

  def set_issuables_index_only_actions
    %i[index]
  end

  before_action :check_feature_enabled!
  before_action :check_issues_available!

  before_action :set_issuables_index, if: ->(c) { c.set_issuables_index_only_actions.include?(c.action_name.to_sym) }

  before_action do
    push_frontend_feature_flag(:jira_integration, @project)
    push_frontend_feature_flag(:vue_issuables_list, @project)
  end

  def index
    @issues = @issuables
  end

  def data
    jira_issues = @project.jira_service.client.Issue.jql("PROJECT='GL' ORDER BY created DESC", { max_results: 50, start_at: 0 }).map do |jira_issue|
      {
        project_id: @project.id,
        title: jira_issue.summary,
        created_at: jira_issue.created,
        updated_at: jira_issue.updated,
        closed_at: jira_issue.resolutiondate,
        external_tracker: "Jira",
        labels: jira_issue.labels.map do |name|
          {
            name: name,
            color: "#b728d9",
            text_color: "#FFFFFF"
          }
        end,
        author: {
          id: 1,
          name: jira_issue.creator['displayName'],
          username: jira_issue.creator['name'],
          avatar_url: "http://127.0.0.1:3000/uploads/-/system/user/avatar/1/avatar.png",
          web_url: "http://127.0.0.1:3000/root"
        },
        assignees: [
          {
            id: 1,
            name: jira_issue.assignee&.displayName,
            username: jira_issue.assignee&.name,
            avatar_url: "http://127.0.0.1:3000/uploads/-/system/user/avatar/1/avatar.png",
            web_url: "http://127.0.0.1:3000/root"
          }
        ],
        web_url: "#{jira_issue.client.options[:site]}projects/#{jira_issue.project.key}/issues/#{jira_issue.key}",
        references: {
          short: "#39",
          relative: jira_issue.key,
          full: "gitlab-org/gitlab-shell#39"
        }
      }
    end

    render json: jira_issues
  end

  protected

  def finder_type
    IssuesFinder
  end

  def check_feature_enabled!
    return render_404 unless Feature.enabled?(:jira_integration, @project)
  end
end
