import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import ThreatMonitoringApp from './components/app.vue';
import createStore from './store';

export default () => {
  const el = document.querySelector('#js-threat-monitoring-app');
  const {
    wafStatisticsEndpoint,
    networkPolicyStatisticsEndpoint,
    environmentsEndpoint,
    chartEmptyStateSvgPath,
    emptyStateSvgPath,
    wafNoDataSvgPath,
    networkPolicyNoDataSvgPath,
    documentationPath,
    defaultEnvironmentId,
    showUserCallout,
    userCalloutId,
    userCalloutsPath,
  } = el.dataset;

  const store = createStore();
  store.dispatch('threatMonitoring/setEndpoints', {
    wafStatisticsEndpoint,
    networkPolicyStatisticsEndpoint,
    environmentsEndpoint,
  });

  return new Vue({
    el,
    store,
    render(createElement) {
      return createElement(ThreatMonitoringApp, {
        props: {
          chartEmptyStateSvgPath,
          emptyStateSvgPath,
          wafNoDataSvgPath,
          networkPolicyNoDataSvgPath,
          documentationPath,
          defaultEnvironmentId: parseInt(defaultEnvironmentId, 10),
          showUserCallout: parseBoolean(showUserCallout),
          userCalloutId,
          userCalloutsPath,
        },
      });
    },
  });
};
