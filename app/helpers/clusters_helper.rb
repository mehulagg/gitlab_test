# frozen_string_literal: true

module ClustersHelper
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

  def js_clusters_list_data(path = nil)
    {
      ancestor_help_path: help_page_path('user/group/clusters/index', anchor: 'cluster-precedence'),
      endpoint: path,
      img_tags: {
        aws: { path: image_path('illustrations/logos/amazon_eks.svg'), text: s_('ClusterIntegration|Amazon EKS') },
        default: { path: image_path('illustrations/logos/kubernetes.svg'), text: _('Kubernetes Cluster') },
        gcp: { path: image_path('illustrations/logos/google_gke.svg'), text: s_('ClusterIntegration|Google GKE') }
      }
    }
  end

  def js_cluster_form_data(cluster, can_edit)
    {
      enabled: cluster.enabled?.to_s,
      editable: can_edit.to_s,
      environment_scope: cluster.environment_scope,
      base_domain: cluster.base_domain,
      application_ingress_external_ip: cluster.application_ingress_external_ip,
      auto_devops_help_path: help_page_path('topics/autodevops/index'),
      external_endpoint_help_path: help_page_path('user/clusters/applications.md', anchor: 'pointing-your-dns-at-the-external-endpoint')
    }
  end

  def js_cluster_new(new_user_path, user_cluster)
    {
      new_user_path: new_user_path,
      allow_user_defined_namespace: user_cluster.allow_user_defined_namespace?.to_s,
      cluster_connect_help_path: help_page_path('user/project/clusters/add_remove_clusters', anchor: 'add-existing-cluster'),
      managed_clusters_help_link: help_page_path('user/project/clusters/index.md', anchor: 'gitlab-managed-clusters'),
      rbac_help_link: help_page_path('user/project/clusters/add_remove_clusters.md', anchor: 'access-controls')
    }
  end

  # This method is depreciated and will be removed when associated HAML files are moved to JavaScript
  def provider_icon(provider = nil)
    img_data = js_clusters_list_data.dig(:img_tags, provider&.to_sym) ||
               js_clusters_list_data.dig(:img_tags, :default)

    image_tag img_data[:path], alt: img_data[:text], class: 'gl-h-full'
  end

  def render_gcp_signup_offer
    return if Gitlab::CurrentSettings.current_application_settings.hide_third_party_offers?
    return unless show_gcp_signup_offer?

    content_tag :section, class: 'no-animate expanded' do
      render 'clusters/clusters/gcp_signup_offer_banner'
    end
  end

  def render_cluster_info_tab_content(tab, expanded)
    case tab
    when 'environments'
      render_if_exists 'clusters/clusters/environments'
    when 'health'
      render_if_exists 'clusters/clusters/health'
    when 'apps'
      render 'applications'
    when 'settings'
      render 'advanced_settings_container'
    else
      render('details', expanded: expanded)
    end
  end

  def cluster_type_label(cluster_type)
    case cluster_type
    when 'project_type'
      s_('ClusterIntegration|Project cluster')
    when 'group_type'
      s_('ClusterIntegration|Group cluster')
    when 'instance_type'
      s_('ClusterIntegration|Instance cluster')
    else
      Gitlab::ErrorTracking.track_and_raise_for_dev_exception(
        ArgumentError.new('Cluster Type Missing'),
        cluster_error: { error: 'Cluster Type Missing', cluster_type: cluster_type }
      )
      _('Cluster')
    end
  end

  def has_rbac_enabled?(cluster)
    return cluster.platform_kubernetes_rbac? if cluster.platform_kubernetes

    cluster.provider.has_rbac_enabled?
  end

  def project_cluster?(cluster)
    cluster.cluster_type.in?('project_type')
  end

  def cluster_created?(cluster)
    !cluster.status_name.in?(%i/scheduled creating/)
  end

  def can_admin_cluster?(user, cluster)
    can?(user, :admin_cluster, cluster)
  end
end
