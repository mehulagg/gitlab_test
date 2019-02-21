# frozen_string_literal: true

module Gitlab
  module Prometheus
    class MetricGroup
      prepend EE::Gitlab::Prometheus::MetricGroup # rubocop: disable Cop/InjectEnterpriseEditionModule
      include ActiveModel::Model

      attr_accessor :name, :priority, :metrics

      validates :name, :priority, :metrics, presence: true

      def self.common_metrics
        all_groups = ::PrometheusMetric.common.group_by(&:group_title).map do |name, metrics|
          MetricGroup.new(
            name: name,
            priority: metrics.map(&:priority).max,
            metrics: group_queries_by_chart(metrics)
          )
        end

        all_groups.sort_by(&:priority).reverse
      end

      def self.group_queries_by_chart(metrics)
        queries_by_metric = {}

        metrics.each do |metric|
          metric_info = metric.metric_info
          queries_by_metric[metric_info] ||= []
          queries_by_metric[metric_info] << metric.query_info
        end

        queries_by_metric.map do |metric_info, queries|
          Gitlab::Prometheus::Metric.new(metric_info.merge(queries: queries))
        end
      end

      # EE only
      def self.for_project(_)
        common_metrics
      end
    end
  end
end
