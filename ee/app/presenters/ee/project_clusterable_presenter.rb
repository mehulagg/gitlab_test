# frozen_string_literal: true

module EE
  module ProjectClusterablePresenter
    extend ::Gitlab::Utils::Override

    override :metrics_dashboard_path
    def metrics_dashboard_path(cluster)
      metrics_dashboard_project_cluster_path(clusterable, cluster)
    end
  end
end
