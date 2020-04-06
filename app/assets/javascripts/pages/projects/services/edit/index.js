import IntegrationSettingsForm from '~/integrations/integration_settings_form';
import PrometheusMetrics from '~/prometheus_metrics/custom_metrics';
import PrometheusAlerts from '~/prometheus_alerts';
import initAlertsSettings from '~/alerts_service_settings';

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
  initAlertsSettings(document.querySelector('.js-alerts-service-settings'));
});
