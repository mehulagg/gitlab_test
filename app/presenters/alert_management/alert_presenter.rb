# frozen_string_literal: true

module AlertManagement
  class AlertPresenter < Gitlab::View::Presenter::Delegated
    include Gitlab::Utils::StrongMemoize
    include IncidentManagement::Settings

    MARKDOWN_LINE_BREAK = "  \n".freeze
    HORIZONTAL_LINE = "\n\n---\n\n".freeze
    RESERVED_ANNOTATIONS = %w(gitlab_incident_markdown gitlab_y_label title).freeze
    GENERIC_ALERT_SUMMARY_ANNOTATIONS = %w(monitoring_tool service hosts).freeze
    INCIDENT_LABEL_NAME = ::IncidentManagement::CreateIncidentLabelService::LABEL_PROPERTIES[:title].freeze

    def initialize(alert, _attributes = {})
      super

      @alert = alert
      @project = alert.project
    end

    def start_time
      started_at&.strftime('%d %B %Y, %-l:%M%p (%Z)')
    end

    # ------- Issues -----------
    def issue_description
      [
        issue_summary_markdown,
        alert_markdown,
        incident_management_setting.issue_template_content
      ].compact.join(HORIZONTAL_LINE)
    end

    # -------- Emails -----------
    def full_title
      [environment&.name, alert_title].compact.join(': ')
    end

    def project_full_path
      project.full_path
    end

    def performance_dashboard_link
      if environment
        metrics_project_environment_url(project, environment)
      else
        metrics_project_environments_url(project)
      end
    end

    def show_performance_dashboard_link?
      prometheus_alert.present?
    end

    def show_incident_issues_link?
      incident_management_setting.create_issue?
    end

    def incident_issues_link
      project_issues_url(project, label_name: INCIDENT_LABEL_NAME)
    end

    def valid?
      project && title && starts_at
    end

    private

    attr_reader :alert, :project
    delegate :alert_markdown, :full_query, :parsed_payload, :alert_title, to: :parsed_payload

    def parsed_payload
      strong_memoize(:parsed_payload) do
        alert.parsed_payload
      end
    end

    def issue_summary_markdown
      <<~MARKDOWN.chomp
        #### Summary

        #{metadata_list}
        #{alert_details}#{metric_embed_for_alert}
      MARKDOWN
    end

    def metadata_list
      metadata = []

      metadata << list_item('Start time', start_time) if start_time.present?
      metadata << list_item('Severity', severity) if severity.present?
      metadata << list_item('full_query', backtick(full_query)) if full_query.present?
      metadata << list_item('Service', service) if service.present?
      metadata << list_item('Monitoring tool', monitoring_tool) if monitoring_tool.present?
      metadata << list_item('Hosts', host_links) if hosts.any?
      metadata << list_item('Description', description) if description.present?

      metadata.join(MARKDOWN_LINE_BREAK)
    end

    def host_links
      Array(hosts).join(' ')
    end

    def alert_details
      if details.present?
        <<~MARKDOWN.chomp

          #### Alert Details

          #{details_list}
        MARKDOWN
      end
    end

    def details_list
      alert.details
        .reject { |label, value| label.in?(RESERVED_ANNOTATIONS | GENERIC_ALERT_SUMMARY_ANNOTATIONS) }
        .map { |label, value| list_item(label, value) }
        .join(MARKDOWN_LINE_BREAK)
    end

    def list_item(key, value)
      "**#{key}:** #{value}".strip
    end

    def backtick(value)
      "`#{value}`"
    end

    def metric_embed_for_alert
      "\n[](#{metrics_dashboard_url})" if metrics_dashboard_url
    end
  end
end
