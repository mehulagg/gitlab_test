# frozen_string_literal: true
#
module Metrics
  module Dashboard
    class ClusterMetricsEmbedService < Metrics::Dashboard::DynamicEmbedService
      # What is usually handled by a sequence is handled in the ClusterDashboardService
      # which is called when getting base_dashboard via Gitlab::Metrics::Dashboard::Finder
      # Endpoint insert is Handled by base_dashboard finder
      SEQUENCE = [].freeze

      class << self
        def valid_params?(params)
          [
            params[:cluster],
            params[:embedded] == 'true',
            params[:group].present?,
            params[:title].present?,
            params[:y_label].present?
          ].all?
        end
      end

      private

      def base_dashboard
        strong_memoize(:base_dashboard) do
          cluster_dashboard_params = params.slice(:cluster, :cluster_type)
          Gitlab::Metrics::Dashboard::Finder.find(
            project, nil, cluster_dashboard_params
          )[:dashboard].deep_stringify_keys
        end
      end

      # Permissions are handled at the controller level
      def allowed?
        true
      end

      def sequence
        SEQUENCE
      end
    end
  end
end
