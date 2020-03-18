import * as types from './mutation_types';

/*
TODO
- make sure response matches what the actual backend response will be
*/

export default {
  [types.SET_ENDPOINT](state, endpoint) {
    state.endpoint = endpoint;
  },
  [types.REQUEST_REPORT](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_REPORT_SUCCESS](state, response) {
    state.hasError = false;
    state.isLoading = false;
    state.report = response.report;
  },
  [types.RECEIVE_REPORT_ERROR](state) {
    state.isLoading = false;
    state.hasError = true;
    state.report = {};
  },
};
