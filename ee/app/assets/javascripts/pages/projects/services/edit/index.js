import IntegrationSettingsForm from '~/integrations/integration_settings_form';
import PrometheusMetrics from 'ee/prometheus_metrics/prometheus_metrics';
import PrometheusAlerts from 'ee/prometheus_alerts';
import AlertsSettings from 'ee/alerts_settings';

document.addEventListener('DOMContentLoaded', () => {
  const integrationSettingsForm = new IntegrationSettingsForm('.js-integration-settings-form');
  integrationSettingsForm.init();

  const prometheusSettingsWrapper = document.querySelector('.js-prometheus-metrics-monitoring');
  if (prometheusSettingsWrapper) {
    const prometheusMetrics = new PrometheusMetrics('.js-prometheus-metrics-monitoring');
    if (prometheusMetrics.isServiceActive) {
      prometheusMetrics.loadActiveCustomMetrics();
    } else {
      prometheusMetrics.setNoIntegrationActiveState();
    }
  }

  PrometheusAlerts();

  const settingsForm = document.querySelector('.js-integration-settings-form')

  if (settingsForm) {
    const keyField = settingsForm.querySelector('label[for="service_token"] + .col-sm-10');
    const el = document.createElement('div');
    keyField.appendChild(el);

    AlertsSettings(el);
  }
});
