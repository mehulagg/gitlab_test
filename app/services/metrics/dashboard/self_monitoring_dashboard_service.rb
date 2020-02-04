# frozen_string_literal: true

# Fetches the self monitoring metrics dashboard and formats the output.
# Use Gitlab::Metrics::Dashboard::Finder to retrieve dashboards.
module Metrics
  module Dashboard
    class SelfMonitoringDashboardService < ::Metrics::Dashboard::PredefinedDashboardService
      DASHBOARD_PATH = 'config/prometheus/self_monitoring_default.yml'
      DASHBOARD_NAME = 'Default (Self Monitoring)'

      SEQUENCE = [
        STAGES::EndpointInserter,
        STAGES::Sorter
      ].freeze

      class << self
        def valid_params?(params)
          params[:environment]&.project&.self_monitoring? || (params[:dashboard_path] && params[:dashboard_path] == DASHBOARD_PATH)
        end

        def all_dashboard_paths(_project)
          [{
            path: DASHBOARD_PATH,
            display_name: DASHBOARD_NAME,
            default: true,
            system_dashboard: true
          }]
        end
      end
    end
  end
end
