import * as types from './mutation_types';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import { __ } from '~/locale';

export default {
  requestConfig: ({ commit }) => commit(types.REQUEST_CONFIG),
  receiveConfigSuccess: ({ commit }, data) => commit(types.RECEIVE_CONFIG_SUCCESS, data),
  receiveConfigError: ({ commit }) => commit(types.RECEIVE_CONFIG_ERROR),

  fetchConfigData: ({ dispatch }, endpoint) => {
    dispatch('requestConfig');

    return axios
      .get(endpoint)
      .then(({ data }) => dispatch('receiveConfigSuccess', data))
      .catch(error => {
        const message = `${__('There was an error fetching configuration for charts')}: ${
          error.response.data.message
        }`;
        createFlash(message);
        dispatch('receiveConfigError');
      });
  },

  requestChartData: ({ commit }) => commit(types.REQUEST_CHART),
  receiveChartDataSuccess: ({ commit }, data) => commit(types.RECEIVE_CHART_SUCCESS, data),
  receiveChartDataError: ({ commit }) => commit(types.RECEIVE_CHART_ERROR),

  fetchChartData: ({ dispatch, state }, endpoint) => {
    const { activeChart } = state;
    dispatch('requestChartData');

    return axios
      .post(endpoint, {
        query: activeChart.query,
        chart_type: activeChart.type,
      })
      .then(({ data }) => dispatch('receiveChartDataSuccess', data))
      .catch(error => {
        const message = `${__('There was an error gathering the chart data')}: ${
          error.response.data.message
        }`;
        createFlash(message);
        dispatch('receiveChartDataError');
      });
  },

  setActiveTab: ({ commit, state }, key) => {
    const { configData } = state;

    const chart = configData[key];

    commit(types.SET_ACTIVE_TAB, key);
    commit(types.SET_ACTIVE_CHART, chart);
  },
};
