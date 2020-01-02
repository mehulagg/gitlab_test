import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import * as types from '../mutation_types';

// TODO: Revert this name without vuex
export const fetchAlertsVuex = ({ dispatch, commit }, queriesWithAlerts) => {
  dispatch('requestAlerts');

  return Promise.all(
    queriesWithAlerts.map(query =>
      axios
        .get(query.alert_path)
        .then(res =>
          dispatch('requestAlertsSuccess', {
            alertAttributes: res.data,
            metricId: query.metric_id,
          }),
        )
        .catch(err => err),
    ),
  )
    .then(() => {
      commit(types.SET_LOADING, false);
    })
    .catch(() => {
      dispatch('requestAlertsError');
    });
};

export const requestAlerts = ({ commit }) => {
  commit(types.SET_LOADING, true);
};

export const requestAlertsSuccess = ({ commit }, alertData) => {
  commit(types.REQUEST_ALERTS_SUCCESS, alertData);
};

export const requestAlertsError = ({ commit }) => {
  createFlash(s__('PrometheusAlerts|Error fetching alert'));
  commit(types.SET_LOADING, false);
};

export const filterQueriesWithAlerts = ({ commit }, queries) => {
  commit(types.FILTER_QUERIES_WITH_ALERTS, queries);
};

export const createAlerts = ({ commit, dispatch, state }) => {
  commit(types.SET_LOADING, true);

  return Promise.all(
    state.alertsVuex.map(alert =>
      axios
        .post(state.alertsEndpoint, {
          prometheus_metric_id: alert.prometheusMetricId,
          operator: alert.operator,
          threshold: alert.threshold,
        })
        .then(resp => resp.data)
        .catch(err => err),
    ),
  )
    .then(() => dispatch('requestCreateAlertsSuccess'))
    .catch(() => dispatch('requestCreateAlertsError'));
};

export const requestCreateAlertsSuccess = ({ commit }) => {
  commit(types.SET_LOADING, false);
};

export const requestCreateAlertsError = ({ commit }) => {
  // TODO: Show error message
  commit(types.SET_LOADING, false);
};

export const updateAlerts = ({ commit, dispatch }, alerts) => {
  commit(types.SET_LOADING, true);

  return Promise.all(
    alerts.map(alert =>
      axios
        .put(alert.alert_path, { operator: alert.operator, threshold: alert.threshold })
        .then(resp => resp.data)
        .catch(err => err),
    ),
  )
    .then(() => dispatch('requestUpdateAlertsSuccess'))
    .catch(() => dispatch('requestUpdateAlertsError'));
};

export const requestUpdateAlertsSuccess = ({ commit }) => {
  commit(types.SET_LOADING, false);
};

export const requestUpdateAlertsError = ({ commit }) => {
  // TODO: Show error message
  commit(types.SET_LOADING, false);
};

export const deleteAlerts = ({ commit, dispatch }, alerts) => {
  commit(types.SET_LOADING, true);

  return Promise.all(
    alerts.map(alert =>
      axios
        .delete(alert.alertPath)
        .then(resp => resp.data)
        .catch(err => err),
    ),
  )
    .then(() => dispatch('requestDeleteAlertsSuccess'))
    .catch(() => dispatch('requestDeleteAlertsError'));
};

export const requestDeleteAlertsSuccess = ({ commit }) => {
  commit(types.SET_LOADING, false);
};

export const requestDeleteAlertsError = ({ commit }) => {
  // TODO: Show error message
  commit(types.SET_LOADING, false);
};

export const setAlertsEndpoint = ({ commit }, endpoint) => {
  commit(types.SET_ALERTS_ENDPOINT, endpoint);
};

export const updateAlertForm = ({ commit }, data) => {
  commit(types.UPDATE_FORM_ALERT, data);
};

export const addAlertToCreate = ({ commit }) => {
  commit(types.ADD_ALERT_QUEUE_CREATE);
};

export const resetAlertForm = ({ commit }) => {
  commit(types.RESET_ALERT_FORM);
};

export const addAlertToDelete = ({ commit }, alertIndex) => {
  commit(types.ADD_ALERT_TO_DELETE, alertIndex);
};

export const saveChangesAlerts = ({ dispatch }) => {
  dispatch('createAlerts');
  dispatch('deleteAlerts');
  dispatch('updateAlerts');
};
