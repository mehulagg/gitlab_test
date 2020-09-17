# frozen_string_literal: true

module Projects
  module Prometheus
    class AlertPresenter < Gitlab::View::Presenter::Delegated
      GENERIC_ALERT_SUMMARY_ANNOTATIONS = %w(monitoring_tool service hosts).freeze
      MARKDOWN_LINE_BREAK = "  \n".freeze
      INCIDENT_LABEL_NAME = ::IncidentManagement::CreateIncidentLabelService::LABEL_PROPERTIES[:title].freeze
      METRIC_TIME_WINDOW = 30.minutes

      def full_title
        [environment_name, alert_title].compact.join(': ')
      end

      def project_full_path
        project.full_path
      end

      def metric_query
        gitlab_alert&.full_query
      end

      def environment_name
        environment&.name
      end

      def performance_dashboard_link
        if environment
          metrics_project_environment_url(project, environment)
        else
          metrics_project_environments_url(project)
        end
      end

      def show_performance_dashboard_link?
        gitlab_alert.present?
      end

      def show_incident_issues_link?
        project.incident_management_setting&.create_issue?
      end

      def incident_issues_link
        project_issues_url(project, label_name: INCIDENT_LABEL_NAME)
      end

      def start_time
        starts_at&.strftime('%d %B %Y, %-l:%M%p (%Z)')
      end

      def issue_summary_markdown
        <<~MARKDOWN.chomp
          #{metadata_list}
          #{alert_details}#{metric_embed_for_alert}
        MARKDOWN
      end

      def details_list
        strong_memoize(:details_list) do
          details
            .map { |label, value| list_item(label, value) }
            .join(MARKDOWN_LINE_BREAK)
        end
      end

      def metric_embed_for_alert
        "\n[](#{metrics_dashboard_url})" if metrics_dashboard_url
      end

      def metrics_dashboard_url
        strong_memoize(:metrics_dashboard_url) do
          embed_url_for_gitlab_alert || embed_url_for_self_managed_alert
        end
      end

      def details_url
        return unless am_alert

        ::Gitlab::Routing.url_helpers.details_project_alert_management_url(
          project,
          am_alert.iid
        )
      end

      private

      def alert_title
        query_title || title
      end

      def query_title
        return unless gitlab_alert

        "#{gitlab_alert.title} #{gitlab_alert.computed_operator} #{gitlab_alert.threshold} for 5 minutes"
      end

      def metadata_list
        metadata = []

        metadata << list_item('Start time', start_time) if start_time
        metadata << list_item('full_query', backtick(full_query)) if full_query
        metadata << list_item(service.label.humanize, service.value) if service
        metadata << list_item(monitoring_tool.label.humanize, monitoring_tool.value) if monitoring_tool
        metadata << list_item(hosts.label.humanize, host_links) if hosts
        metadata << list_item('GitLab alert', details_url) if details_url

        metadata.join(MARKDOWN_LINE_BREAK)
      end

      def details
        Gitlab::Utils::InlineHash.merge_keys(payload)
      end

      def alert_details
        if details.present?
          <<~MARKDOWN.chomp

            #### Alert Details

            #{details_list}
          MARKDOWN
        end
      end

      def list_item(key, value)
        "**#{key}:** #{value}".strip
      end

      def backtick(value)
        "`#{value}`"
      end

      GENERIC_ALERT_SUMMARY_ANNOTATIONS.each do |annotation_name|
        define_method(annotation_name) do
          annotations.find { |a| a.label == annotation_name }
        end
      end

      def host_links
        Array(hosts.value).join(' ')
      end

      def embed_url_for_gitlab_alert
        return unless gitlab_alert

        metrics_dashboard_project_prometheus_alert_url(
          project,
          gitlab_alert.prometheus_metric_id,
          environment_id: environment.id,
          embedded: true,
          **alert_embed_window_params(embed_time)
        )
      end

      def embed_url_for_self_managed_alert
        return unless environment && full_query && title

        metrics_dashboard_project_environment_url(
          project,
          environment,
          embed_json: dashboard_for_self_managed_alert.to_json,
          embedded: true,
          **alert_embed_window_params(embed_time)
        )
      end

      def embed_time
        starts_at || Time.current
      end

      def alert_embed_window_params(time)
        {
          start: format_embed_timestamp(time - METRIC_TIME_WINDOW),
          end: format_embed_timestamp(time + METRIC_TIME_WINDOW)
        }
      end

      def format_embed_timestamp(time)
        time.utc.strftime('%FT%TZ')
      end

      def dashboard_for_self_managed_alert
        {
          panel_groups: [{
            panels: [{
              type: 'area-chart',
              title: title,
              y_label: y_label,
              metrics: [{
                query_range: full_query
              }]
            }]
          }]
        }
      end
    end
  end
end
