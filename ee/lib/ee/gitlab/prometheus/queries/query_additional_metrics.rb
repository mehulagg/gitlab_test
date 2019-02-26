# frozen_string_literal: true

module EE
  module Gitlab
    module Prometheus
      module Queries
        module QueryAdditionalMetrics
          def query_metrics(project, environment, query_context)
            super.map(&query_with_alert(project, environment))
          end

          protected

          def query_with_alert(project, environment)
            alerts_map =
              project.prometheus_alerts.each_with_object({}) do |alert, hsh|
                hsh[alert[:prometheus_metric_id]] = alert.prometheus_metric_id
              end

            proc do |group|
              group[:metrics] = group[:metrics]&.map do |metric|
                metric[:queries] = metric[:queries]&.map do |item|
                  metric_id = item[:id] || metric[:id]

                  if metric_id && alerts_map[metric_id]
                    item[:alert_path] = alert_path(alerts_map, metric_id, project, environment)
                  end

                  item
                end

                metric
              end

              group
            end
          end

          private

          def alert_path(alerts_map, key, project, environment)
            ::Gitlab::Routing.url_helpers.project_prometheus_alert_path(project, alerts_map[key], environment_id: environment.id, format: :json)
          end
        end
      end
    end
  end
end
