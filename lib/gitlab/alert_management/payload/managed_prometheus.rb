# frozen_string_literal: true

module Gitlab
  module AlertManagement
    module Payload
      class ManagedPrometheus < ::Gitlab::AlertManagement::Payload::Prometheus
        add_attribute :metric_id,
                      paths: [['labels', 'gitlab_alert_id']],
                      type: :integer
        add_attribute :gitlab_prometheus_alert_id,
                      paths: [['labels', 'gitlab_prometheus_alert_id']],
                      type: :integer

        def gitlab_alert
          return unless metric_id || gitlab_prometheus_alert_id

          alerts = Projects::Prometheus::AlertsFinder
            .new(project: project, metric: metric_id, id: gitlab_prometheus_alert_id)
            .execute

          return if alerts.blank? || alerts.size > 1

          alerts.first
        end

        def full_query
          gitlab_alert&.full_query || super
        end

        def environment
          gitlab_alert&.environment || super
        end

        def metrics_dashboard_url
          return unless gitlab_alert

          metrics_dashboard_project_prometheus_alert_url(
            project,
            gitlab_alert.prometheus_metric_id,
            environment_id: environment.id,
            embedded: true,
            **alert_embed_window_params
          )
        end

        def query_title
          return super unless gitlab_alert

          "#{gitlab_alert.title} #{gitlab_alert.computed_operator} #{gitlab_alert.threshold} for 5 minutes"
        end

        private

        def plain_gitlab_fingerprint
          [metric_id, starts_at_raw].join('/')
        end
      end
    end
  end
end
