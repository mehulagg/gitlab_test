# frozen_string_literal: true

module Gitlab
  module AlertManagement
    module Payload
      class Prometheus < Base
        add_attribute :title,
                      paths: [['annotations', 'title'],
                              ['annotations', 'summary'],
                              ['labels', 'alertname']]
        add_attribute :description,
                      paths: [['annotations', 'description']]
        add_attribute :annotations,
                      paths: [['annotations']]
        add_attribute :status,
                      paths: [['status']]
        add_attribute :starts_at,
                      paths: [['startsAt']],
                      type: :rfc3339,
                      fallback: Proc.new { Time.current.utc }
        add_attribute :starts_at_raw,
                      paths: [['startsAt']]
        add_attribute :ends_at,
                      paths: [['endsAt']],
                      type: :rfc3339
        add_attribute :generator_url,
                      paths: [['generatorURL']]
        add_attribute :runbook,
                      paths: [['annotations', 'runbook']]

        add_attribute :alert_markdown,
                      paths: [['annotations', 'gitlab_incident_markdown']]
        add_attribute :environment_name,
                      paths: [['labels', 'gitlab_environment_name']]
        add_attribute :gitlab_y_label,
                      paths: [['annotations', 'gitlab_y_label'],
                              ['annotations', 'title'],
                              ['annotations', 'summary'],
                              ['labels', 'alertname']]

        METRIC_TIME_WINDOW = 30.minutes

        def monitoring_tool
          Gitlab::AlertManagement::Payload::MONITORING_TOOLS[:prometheus]
        end

        # Parses `g0.expr` from `generatorURL`.
        #
        # Example: http://localhost:9090/graph?g0.expr=vector%281%29&g0.tab=1
        def full_query
          return unless generator_url

          uri = URI(generator_url)

          Rack::Utils.parse_query(uri.query).fetch('g0.expr')
        rescue URI::InvalidURIError, KeyError
        end

        def environment
          return unless environment_name

          EnvironmentsFinder.new(project, nil, { name: environment_name })
            .find
            &.first
        end

        def gitlab_fingerprint
          Gitlab::AlertManagement::Fingerprint.generate(plain_gitlab_fingerprint)
        end

        def metrics_dashboard_url
          return unless environment && full_query && title

          metrics_dashboard_project_environment_url(
            project,
            environment,
            embed_json: dashboard_json,
            embedded: true,
            **alert_embed_window_params
          )
        end

        private

        def plain_gitlab_fingerprint
          [starts_at_raw, title, full_query].join('/')
        end

        # Formatted for parsing by JS
        def alert_embed_window_params
          {
            start: (starts_at - METRIC_TIME_WINDOW).utc.strftime('%FT%TZ'),
            end: (starts_at + METRIC_TIME_WINDOW).utc.strftime('%FT%TZ')
          }
        end

        def dashboard_json
          {
            panel_groups: [{
              panels: [{
                type: 'line-graph',
                title: title,
                y_label: y_label,
                metrics: [{
                  query_range: full_query
                }]
              }]
            }]
          }.to_json
        end
      end
    end
  end
end
