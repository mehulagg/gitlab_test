import * as types from './mutation_types';

export default {
  [types.SET_CHART_ENDPOINT](state, endpoint) {
    state.chartEndpoint = endpoint;
  },
  [types.REQUEST_CHART_DATA](state) {
    state.charts.main.isLoading = true;
  },
  [types.RECEIVE_CHART_DATA_SUCCESS](state, data) {
    state.charts.main.hasError = false;
    state.charts.main.isLoading = false;
    state.charts.main.data = data;
  },
  [types.RECEIVE_CHART_DATA_ERROR](state) {
    state.charts.main.isLoading = false;
    state.charts.main.data = null;
    state.charts.main.hasError = true;
  },
};
