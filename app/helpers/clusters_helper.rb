# frozen_string_literal: true

module ClustersHelper
  # EE overrides this
  def has_multiple_clusters?
    false
  end

  def create_new_cluster_label(provider: nil)
    case provider
    when 'aws'
      s_('ClusterIntegration|Create new cluster on EKS')
    when 'gcp'
      s_('ClusterIntegration|Create new cluster on GKE')
    else
      s_('ClusterIntegration|Create new cluster')
    end
  end

  def render_gcp_signup_offer
    return if Gitlab::CurrentSettings.current_application_settings.hide_third_party_offers?
    return unless show_gcp_signup_offer?

    content_tag :section, class: 'no-animate expanded' do
      render 'clusters/clusters/gcp_signup_offer_banner'
    end
  end

  def has_rbac_enabled?(cluster)
    return cluster.platform_kubernetes_rbac? if cluster.platform_kubernetes

    cluster.provider.has_rbac_enabled?
  end

  def cluster_health_data(cluster)
    {
      'clusters-path': clusterable.index_path,
      'metrics-endpoint': clusterable.metrics_cluster_path(cluster, format: :json),
      'dashboard-endpoint': clusterable.metrics_dashboard_path(cluster),
      'documentation-path': help_page_path('user/project/clusters/index', anchor: 'monitoring-your-kubernetes-cluster-ultimate'),
      'empty-getting-started-svg-path': image_path('illustrations/monitoring/getting_started.svg'),
      'empty-loading-svg-path': image_path('illustrations/monitoring/loading.svg'),
      'empty-no-data-svg-path': image_path('illustrations/monitoring/no_data.svg'),
      'empty-unable-to-connect-svg-path': image_path('illustrations/monitoring/unable_to_connect.svg'),
      'settings-path': '',
      'project-path': '',
      'tags-path': ''
    }
  end
end

ClustersHelper.prepend_if_ee('EE::ClustersHelper')
