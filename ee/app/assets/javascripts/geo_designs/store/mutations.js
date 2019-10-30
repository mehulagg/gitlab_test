import Api from 'ee/api';
import * as types from './mutation_types';

export default {
  [types.SET_ENDPOINT](state) {
    state.endpoint = Api.buildUrl(Api.geoDesignsPath);
  },
  [types.SET_FILTER](state, filterIndex) {
    state.currentFilterIndex = filterIndex;
  },
  [types.SET_SEARCH](state, search) {
    state.searchFilter = search;
  },
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
  [types.REQUEST_DESIGNS_BATCH_ACTION](state) {
    state.isLoading = true;
  },
  [types.REQUEST_DESIGNS_BATCH_ACTION_SUCCESS](state) {
    state.isLoading = false;
  },
  [types.REQUEST_DESIGNS_BATCH_ACTION_ERROR](state, error) {
    state.isLoading = false;
    state.error = error;
  },
};
