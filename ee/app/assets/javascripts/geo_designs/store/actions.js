import * as types from './mutation_types';
import createFlash from '~/flash';
import { __ } from '~/locale';

import axios from '~/lib/utils/axios_utils';

export const setEndpoint = ({ commit }) => commit(types.SET_ENDPOINT);
export const setFilter = ({ commit }, filterIndex) => commit(types.SET_FILTER, filterIndex);
export const setSearch = ({ commit }, search) => commit(types.SET_SEARCH, search);

export const requestDesigns = ({ commit }) => commit(types.REQUEST_DESIGNS);
export const receiveDesignsSuccess = ({ commit }, data) =>
  commit(types.RECEIVE_DESIGNS_SUCCESS, data);
export const receiveDesignsError = ({ commit }, error) => {
  createFlash(__('There was an error'));
  commit(types.RECEIVE_DESIGNS_ERROR, error);
};

export const fetchDesigns = ({ state, dispatch }) => {
  dispatch('requestDesigns');

  axios.get(state.endpoint)
    .then(({ data }) => dispatch('receiveDesignsSuccess', data))
    .catch((error) => {
      dispatch('receiveDesignsError', error)
      createFlash(__('There was an error'))
    });
};

export const requestDesignsBatchAction = ({ commit }) => commit(types.REQUEST_DESIGNS_BATCH_ACTION);
export const requestDesignsBatchActionSuccess = ({ commit }) =>
  commit(types.REQUEST_DESIGNS_BATCH_ACTION_SUCCESS);
export const requestDesignsBatchActionError = ({ commit }, error) => {
  createFlash(__('There was an error'));
  commit(types.REQUEST_DESIGNS_BATCH_ACTION_ERROR, error);
};

export const designsBatchAction = ({ state, dispatch }, action) => {
  dispatch('requestDesignsBatchAction');

  axios.post(`${state.endpoint}/${action}`, {})
    .then(() => dispatch('requestDesignsBatchActionSuccess'))
    .catch((error) => {
      dispatch('requestDesignsBatchActionError', error)
      createFlash(__('There was an error'))
    });
};
