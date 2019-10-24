import * as types from './mutation_types';

export default {
  [types.REQUEST_DESIGNS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_DESIGNS_SUCCESS](state, data) {
    state.isLoading = false;
    state.designs = data;
  },
  [types.RECEIVE_DESIGNS_ERROR](state, error) {
    state.isLoading = false;
    state.error = error;
  },
};