import * as types from './mutation_types';

export default {
  [types.REQUEST_DESIGNS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_DESIGNS_SUCCESS](state, data) {
    // Do any needed data transformation to the received payload here
    state.designs = data;
    state.isLoading = false;
  },
  [types.RECEIVE_DESIGNS_ERROR](state, error) {
    state.isLoading = false;
    state.error = error;
  },
};