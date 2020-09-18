import * as types from './mutation_types';

export default {
  [types.REQUEST_SEARCH](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_SEARCH_SUCCESS](state, results) {
    state.isLoading = false;
    state.results = results;
  },
  [types.RECEIVE_SEARCH_ERROR](state) {
    state.isLoading = false;
    state.results = [];
  },
};
