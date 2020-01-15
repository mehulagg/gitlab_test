import Vue from 'vue';
import * as types from '../mutation_types';
import { OPERATORS } from '../../constants';

export default {
  [types.REQUEST_ALERTS_SUCCESS]() {
    /* Previous implementation
    if (alertData.alertAttributes) {
      Vue.set(state.allAlerts, alertData.alertAttributes.alertPath, alertData.alertAttributes);
    } else {
      Vue.delete(state.allAlerts, alertData.alertAttributes.alertPath);
    }
    */
    // if (state.availableAlertsFromQueries) {
    //   Vue.set(state.availableAlertsFromQueries, 0, alertData);
    // } else {
    //   state.push(alertData);
    // }
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
    });
  },
  [types.RESET_ALERT_FORM](state) {
    state.alertsVuex.splice(0);
    state.alertsVuex.push({
      alert: {},
      operator: OPERATORS.greaterThan,
      threshold: null,
      prometheusMetricId: null,
    });
  },
  [types.ADD_ALERT_TO_DELETE](state, alertIndex) {
    if (state.alertsVuex[alertIndex]) {
      state.alertsToDelete.push({
        alertPath: state.alertsVuex[alertIndex].alert.alert_path,
      });
    }
    state.alertsVuex.splice(alertIndex, 1);
  },
  [types.FILTER_ALERTS_FROM_GROUPS](state, panelGroups) {
    // TODO: Maybe use the state for the panelGroups instead?
    panelGroups.forEach(group => {
      group.panels.forEach(panel => {
        panel.metrics.forEach(metric => {
          if (metric.alert_path) {
            Vue.set(state.availableAlertsFromQueries, metric.metricId, {
              ...metric,
            });
          }
        });
      });
    });
  },
};
