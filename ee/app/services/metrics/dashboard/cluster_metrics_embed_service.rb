# frozen_string_literal: true
#
module Metrics
  module Dashboard
    class ClusterMetricsEmbedService < ::Metrics::Dashboard::BaseEmbedService
      DASHBOARD_PATH = 'ee/config/prometheus/cluster_metrics.yml'
      DASHBOARD_NAME = 'Cluster'

      SEQUENCE = [
        STAGES::CommonMetricsInserter,
        STAGES::ClusterEmbedFilter,
        STAGES::ClusterEndpointInserter
      ].freeze

      class << self
        def valid_params?(params)
          params[:cluster] && !!params[:embedded].nil?
        end
      end

      private

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
