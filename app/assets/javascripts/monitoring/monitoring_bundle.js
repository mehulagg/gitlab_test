import Vue from 'vue';
import { GlToast } from '@gitlab/ui';
import { parseBoolean } from '~/lib/utils/common_utils';
import { getParameterValues } from '~/lib/utils/url_utility';
import Dashboard from 'ee_else_ce/monitoring/components/dashboard/dashboard.vue';
import createStore from './stores';

Vue.use(GlToast);

export default (props = {}) => {
  const el = document.getElementById('prometheus-graphs');
  let features = {}

  if (el && el.dataset) {
    if (gon.features) {
      features = {
        prometheusEndpointEnabled: gon.features.environmentMetricsUsePrometheusEndpoint,
        additionalPanelTypesEnabled: gon.features.environmentMetricsAdditionalPanelTypes,
      }
    }

    const [currentDashboard] = getParameterValues('dashboard');
    const store = createStore({
      ...el.dataset,
      ...features,
    });
    // eslint-disable-next-line no-new
    new Vue({
      el,
      store,
      render(createElement) {
        return createElement(Dashboard, {
          props: {
            ...el.dataset,
            currentDashboard,
            hasMetrics: parseBoolean(el.dataset.hasMetrics),
            ...props,
          },
        });
      },
    });
  }
};
