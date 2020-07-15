# frozen_string_literal: true

class PrometheusService < MonitoringService
  include PrometheusAdapter

  has_many :prometheus_api_configs, :class_name => 'Metrics::PrometheusApiConfig'

  before_save :synchronize_service_state

  after_save :clear_reactive_cache!

  after_commit :track_events

  after_create_commit :create_default_alerts

  scope :preload_project, -> { preload(:project) }
  scope :with_clusters_with_cilium, -> { joins(project: [:clusters]).merge(Clusters::Cluster.with_available_cilium) }

  def initialize_properties
    if properties.nil?
      self.properties = {}
    end
  end

  def show_active_box?
    false
  end

  def title
    'Prometheus'
  end

  def description
    s_('PrometheusService|Time-series monitoring service')
  end

  def self.to_param
    'prometheus'
  end

  def fields
    [
      {
        type: 'checkbox',
        name: 'manual_configuration',
        title: s_('PrometheusService|Active'),
        required: true
      },
      {
        type: 'text',
        name: 'api_url',
        title: 'API URL',
        placeholder: s_('PrometheusService|Prometheus API Base URL, like http://prometheus.example.com/'),
        required: true
      },
      {
        type: 'text',
        name: 'google_iap_audience_client_id',
        title: 'Google IAP Audience Client ID',
        placeholder: s_('PrometheusService|Client ID of the IAP secured resource (looks like IAP_CLIENT_ID.apps.googleusercontent.com)'),
        autocomplete: 'off',
        required: false
      },
      {
        type: 'textarea',
        name: 'google_iap_service_account_json',
        title: 'Google IAP Service Account JSON',
        placeholder: s_('PrometheusService|Contents of the credentials.json file of your service account, like: { "type": "service_account", "project_id": ... }'),
        required: false
      }
    ]
  end

  # Check we can connect to the Prometheus API
  def test(*args)
    prometheus_client.ping
    { success: true, result: 'Checked API endpoint' }
  rescue Gitlab::PrometheusClient::Error => err
    { success: false, result: err }
  end

  def prometheus_available?
    return false if template?
    return false unless project

    project.all_clusters.enabled.eager_load(:application_prometheus).any? do |cluster|
      cluster.application_prometheus&.available?
    end
  end

  def allow_local_api_url?
    allow_local_requests_from_web_hooks_and_services? ||
    (self_monitoring_project? && internal_prometheus_url?)
  end

  def configured?
    prometheus_api_configs.any?
  end

  private

  def allow_local_requests_from_web_hooks_and_services?
    current_settings.allow_local_requests_from_web_hooks_and_services?
  end

  def should_return_client?
    api_url.present? && manual_configuration? && active? && valid?
  end

  def current_settings
    Gitlab::CurrentSettings.current_application_settings
  end

  def synchronize_service_state
    self.active = prometheus_api_configs.any?

    true
  end

  def track_events
    if enabled_manual_prometheus?
      Gitlab::Tracking.event('cluster:services:prometheus', 'enabled_manual_prometheus')
    elsif disabled_manual_prometheus?
      Gitlab::Tracking.event('cluster:services:prometheus', 'disabled_manual_prometheus')
    end

    true
  end

  def enabled_manual_prometheus?
    manual_configuration_changed? && manual_configuration?
  end

  def disabled_manual_prometheus?
    manual_configuration_changed? && !manual_configuration?
  end

  def create_default_alerts
    return unless project_id

    Prometheus::CreateDefaultAlertsWorker.perform_async(project_id)
  end
end
