import Vue from 'vue';
import store from './store';
import ExternalDashboardForm from './components/external_dashboard.vue';
import PrometheusMetrics from 'ee/prometheus_metrics/prometheus_metrics';

// import PrometheusMetrics from '../../javascripts/prometheus_metrics/prometheus_metrics.js';

document.addEventListener('DOMContentLoaded', () => {
    const prometheusSettingsWrapper = document.querySelector('.js-prometheus-metrics-monitoring');
    if (prometheusSettingsWrapper) {
        const prometheusMetrics = new PrometheusMetrics('.js-prometheus-metrics-monitoring');
        if (prometheusMetrics.isServiceActive) {
            prometheusMetrics.loadActiveCustomMetrics();
        } else {
            prometheusMetrics.setNoIntegrationActiveState();
        }
    }
});

export default () => {
  const el = document.querySelector('.js-operation-settings');

  return new Vue({
    el,
    store: store(el.dataset),
    render(createElement) {
      return createElement(ExternalDashboardForm);
    },
  });
};
