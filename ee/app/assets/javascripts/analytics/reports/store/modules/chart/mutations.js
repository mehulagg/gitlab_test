import * as types from './mutation_types';

export default {
  [types.REQUEST_CHART_SERIES_DATA](state) {
    state.isLoading = true;
    state.error = false;
  },
  [types.RECEIVE_CHART_SERIES_DATA_SUCCESS](state, data) {
    state.isLoading = false;
    state.error = false;
    state.data = data;
  },
  [types.RECEIVE_CHART_SERIES_DATA_ERROR](state) {
    state.isLoading = false;
    state.error = true;
  },
};
