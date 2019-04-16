import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';

export default {
  setEndpoint: ({ commit }, endpoint) => commit(types.SET_ENDPOINT, endpoint),

  requestMetrics: ({ commit }) => commit(types.REQUEST_METRICS),

  fetchMetrics: ({ state, dispatch }) => {
    dispatch('requestMetrics');

    return axios
      .get(state.endpoint)
      .then(response => dispatch('receiveMetricsSuccess', response.data))
      .catch(() => dispatch('receiveMetricsError'));
  },

  receiveMetricsSuccess: ({ commit }, response) => {
    commit(types.RECEIVE_METRICS_SUCCESS, response);
  },

  receiveMetricsError: ({ commit }) => commit(types.RECEIVE_METRICS_ERROR),
};
