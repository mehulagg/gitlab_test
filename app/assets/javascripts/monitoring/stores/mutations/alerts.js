import Vue from 'vue';
import * as types from '../mutation_types';
import { OPERATORS } from '../../constants';

export default {
  [types.REQUEST_ALERTS_SUCCESS](state, data) {
    // Verify if the first element has a prometheus_metric_id attached to it, if there's one push a new element, otherwise override
    const alert = {
      operator: data.alertAttributes.operator,
      threshold: data.alertAttributes.threshold,
      prometheusMetricId: data.metricId,
      alert: {
        alertPath: data.alertAttributes.alert_path,
      },
      visible: true,
    };

    if (state.alertsVuex[0].prometheusMetricId) {
      state.alertsVuex.push(alert);
    } else {
      Vue.set(state.alertsVuex, 0, alert);
    }

    state.newForm = false;
  },
  [types.FILTER_QUERIES_WITH_ALERTS](state, queries) {
    const filteredQueries = queries.filter(query => query.alert_path);

    filteredQueries.forEach(query => {
      state.queriesWithAlerts.push(query);
    });
  },
  [types.SET_LOADING](state, value) {
    state.isLoading = value;
  },
  [types.SET_ALERTS_ENDPOINT](state, endpoint) {
    state.alertsEndpoint = endpoint;
  },
  [types.UPDATE_FORM_ALERT](state, data) {
    const cur = state.alertsVuex[data.index];

    Vue.set(state.alertsVuex, data.index, {
      operator: data.operator || cur.operator,
      threshold: data.threshold || cur.threshold,
      prometheusMetricId: data.prometheusMetricId || cur.prometheusMetricId,
    });
  },
  [types.ADD_ALERT_QUEUE_CREATE](state) {
    state.alertsVuex.push({
      alert: {},
      operator: OPERATORS.greaterThan,
      threshold: null,
      prometheusMetricId: null,
      visible: true,
    });
  },
  [types.RESET_ALERT_FORM](state) {
    state.alertsVuex.splice(0);
    state.alertsVuex.push({
      alert: {},
      operator: OPERATORS.greaterThan,
      threshold: null,
      prometheusMetricId: null,
      visible: true,
    });
  },
  [types.ADD_ALERT_TO_DELETE](state, alertIndex) {
    if (state.alertsVuex[alertIndex]) {
      state.alertsToDelete.push({
        alertPath: state.alertsVuex[alertIndex].alert.alert_path,
      });

      Vue.set(state.alertsVuex, alertIndex, { ...state.alertsVuex[alertIndex], visible: false });
    }
  },
  [types.FILTER_ALERTS_FROM_GROUPS](state, panelGroups) {
    // TODO: Maybe use the state for the panelGroups instead?
    panelGroups.forEach(group => {
      group.panels.forEach(panel => {
        panel.metrics.forEach(metric => {
          if (metric.alert_path) {
            Vue.set(state.availableAlertsFromQueries, metric.metricId, {
              metricId: metric.metricId, // TODO: Probably use the key name instead of this prop for more tidiness?
              alert_path: metric.alert_path,
              metric_id: metric.metric_id,
            });
          }
        });
      });
    });
  },
};
