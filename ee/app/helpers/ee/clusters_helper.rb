# frozen_string_literal: true

module EE
  module ClustersHelper
    def show_cluster_health_graphs?
      clusterable.feature_available?(:cluster_health)
    end
  end
end
