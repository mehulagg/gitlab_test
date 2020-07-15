# frozen_string_literal: true

module Metrics
  class PrometheusAPIConfig < ApplicationRecord
    self.table_name = 'metrics_prometheus_api_config'

    belongs_to :project_services_prometheus_service, :class_name => 'ProjectServices::PrometheusService', inverse_of: :prometheus_api_config
    belongs_to :clusters_applications_prometheus, :class_name => 'Clusters::Applications::Prometheus', inverse_of: :prometheus_api_config

    #  Access to prometheus is directly through the API
    prop_accessor :api_url
    prop_accessor :google_iap_service_account_json
    prop_accessor :google_iap_audience_client_id
    boolean_accessor :manual_configuration

    # We need to allow the self-monitoring project to connect to the internal
    # Prometheus instance.
    # Since the internal Prometheus instance is usually a localhost URL, we need
    # to allow localhost URLs when the following conditions are true:
    # 1. project is the self-monitoring project.
    # 2. api_url is the internal Prometheus URL.
    with_options presence: true do
      validates :api_url, public_url: true, if: ->(object) { object.manual_configuration? && !object.allow_local_api_url? }
      validates :api_url, url: true, if: ->(object) { object.manual_configuration? && object.allow_local_api_url? }
    end

    def api_url
      clusters_applications_prometheus.present? ? clusters_applications_prometheus.proxy_url : super
    end

    def headers
      clusters_applications_prometheus.present? ? clusters_applications_prometheus.proxy_headers : super
    end

    def behind_iap?
      manual_configuration? && google_iap_audience_client_id.present? && google_iap_service_account_json.present?
    end

    def iap_client
      @iap_client ||= Google::Auth::Credentials.new(Gitlab::Json.parse(google_iap_service_account_json), target_audience: google_iap_audience_client_id).client
    end

    def self_monitoring_project?
      project && project.id == current_settings.self_monitoring_project_id
    end

    def internal_prometheus_url?
      api_url.present? && api_url == ::Gitlab::Prometheus::Internal.uri
    end
  end
end
