# frozen_string_literal: true

module Clusters
  module Applications
    class PrometheusConfigService
      def initialize(project, cluster)
        @project = project
        @cluster = cluster
      end

      def execute(config)
        if has_alerts?
          generate_alert_manager(config)
        else
          reset_alert_manager(config)
        end
      end

      private

      attr_reader :project, :cluster

      def reset_alert_manager(config)
        config = set_alert_manager_enabled(config, false)
        config.delete('alertmanagerFiles')
        config['serverFiles']['alerts'] = {}

        config
      end

      def generate_alert_manager(config)
        config = set_alert_manager_enabled(config, true)
        config = set_alert_manager_files(config)

        set_alert_manager_groups(config)
      end

      def set_alert_manager_enabled(config, enabled)
        config['alertmanager']['enabled'] = enabled

        config
      end

      def set_alert_manager_files(config)
        config['alertmanagerFiles'] = {
          'alertmanager.yml' => {
            'receivers' => alert_manager_receivers_params,
            'route' => alert_manager_route_params
          }
        }

        config
      end

      def set_alert_manager_groups(config)
        config['serverFiles']['alerts']['groups'] ||= []

        environments_with_alerts.each do |env_name, alerts|
          index = config['serverFiles']['alerts']['groups'].find_index do |group|
            group['name'] == env_name
          end

          if index
            config['serverFiles']['alerts']['groups'][index]['rules'] = alerts
          else
            config['serverFiles']['alerts']['groups'] << {
              'name' => env_name,
              'rules' => alerts
            }
          end
        end

        config
      end

      def alert_manager_receivers_params
        [
          {
            'name' => 'gitlab',
            'webhook_configs' => [
              {
                'url' => notify_url,
                'send_resolved' => true
              }
            ]
          }
        ]
      end

      def alert_manager_route_params
        {
          'receiver' => 'gitlab',
          'group_wait' => '30s',
          'group_interval' => '5m',
          'repeat_interval' => '4h'
        }
      end

      def notify_url
        ::Gitlab::Routing.url_helpers.notify_namespace_project_prometheus_alerts_url(
          namespace_id: project.namespace.path,
          project_id: project.path,
          format: :json
        )
      end

      def has_alerts?
        environments_with_alerts.values.flatten.any?
      end

      def environments_with_alerts
        @environments_with_alerts ||=
          environments.each_with_object({}) do |environment, hsh|
            name = rule_name(environment)
            hsh[name] = alerts(environment)
          end
      end

      def rule_name(environment)
        "#{environment.name}.rules"
      end

      def alerts(environment)
        environment.prometheus_alerts.map do |alert|
          alert.to_param.tap do |hash|
            hash['expr'] %= Gitlab::Prometheus::QueryVariables.call(environment)
          end
        end
      end

      def environments
        project.environments_for_scope(cluster.environment_scope)
      end
    end
  end
end
