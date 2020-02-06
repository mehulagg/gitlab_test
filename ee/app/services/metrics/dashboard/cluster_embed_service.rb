# frozen_string_literal: true

# Responsible for returning an embed containing the specified
# metrics chart for a cluster. Creates panels based on the
# matching metric stored in the database.
#
# Use Gitlab::Metrics::Dashboard::Finder to retrive dashboards.
module Metrics
  module Dashboard
    class ClusterEmbedService < ::Metrics::Dashboard::BaseEmbedService
      # include Gitlab::Utils::StrongMemoize
      #
      class << self
        def valid_params?(params)
          [
            params[:embedded] == true,
            params[:cluster].present?
          ].all?
        end
      end

      def raw_dashboard
        # panels_not_found!(alert_id: alert_id) unless alert && prometheus_metric

        { 'panel_groups' => [{ 'panels' => [panel] }] }
      end

      private

      def allowed?
        Ability.allowed?(current_user, :read_prometheus_alerts, project)
      end

      def prometheus_metric
        strong_memoize(:prometheus_metric) do
          PrometheusMetricsFinder.new(id: cluster.prometheus_metric_id).execute.first
        end
      end

      def panel
        {
          title: prometheus_metric.title,
          y_label: prometheus_metric.y_label,
          metrics: [prometheus_metric.to_metric_hash]
        }
      end
    end
  end
end
