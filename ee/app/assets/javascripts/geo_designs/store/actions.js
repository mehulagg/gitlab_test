import * as types from './mutation_types';
import createFlash from '~/flash';
import { __ } from '~/locale';
import { FILTER_STATES } from './constants';

import axios from '~/lib/utils/axios_utils';

// Core Actions
export const setEndpoint = ({ commit }) => commit(types.SET_ENDPOINT);

// Fetch Designs
export const requestDesigns = ({ commit }) => commit(types.REQUEST_DESIGNS);
export const receiveDesignsSuccess = ({ commit }, data) =>
  commit(types.RECEIVE_DESIGNS_SUCCESS, data);
export const receiveDesignsError = ({ commit }, error) => {
  createFlash(__('There was an error'));
  commit(types.RECEIVE_DESIGNS_ERROR, error);
};

export const fetchDesigns = ({ state, dispatch }) => {
  dispatch('requestDesigns');

  const statusFilterName = state.filterOptions[state.currentFilterIndex];
  const query = {
    page: state.currentPage ? state.currentPage : 1,
    search: state.searchFilter ? state.searchFilter : null,
    sync_status: statusFilterName === FILTER_STATES.ALL ? null : statusFilterName,
  };

  axios
    .get(state.endpoint, { params: query })
    .then(res => {
      dispatch('receiveDesignsSuccess', {
        data: res.data,
        perPage: res.headers['x-per-page'],
        total: res.headers['x-total'],
      });
    })
    .catch(error => {
      dispatch('receiveDesignsError', error);
      createFlash(__('There was an error'));
    });
};

// Designs Batch Action
export const requestDesignsBatchAction = ({ commit }) => commit(types.REQUEST_DESIGNS_BATCH_ACTION);
export const requestDesignsBatchActionSuccess = ({ commit, dispatch }) => {
  commit(types.REQUEST_DESIGNS_BATCH_ACTION_SUCCESS);
  dispatch('fetchDesigns');
};
export const requestDesignsBatchActionError = ({ commit }, error) => {
  createFlash(__('There was an error'));
  commit(types.REQUEST_DESIGNS_BATCH_ACTION_ERROR, error);
};

export const designsBatchAction = ({ state, dispatch }, action) => {
  dispatch('requestDesignsBatchAction');

  axios
    .post(`${state.endpoint}/${action}`, {})
    .then(() => dispatch('requestDesignsBatchActionSuccess'))
    .catch(error => {
      dispatch('requestDesignsBatchActionError', error);
      createFlash(__('There was an error'));
    });
};

// Design Action
export const requestDesignAction = ({ commit }) => commit(types.REQUEST_DESIGN_ACTION);
export const requestDesignActionSuccess = ({ commit, dispatch }) => {
  commit(types.REQUEST_DESIGN_ACTION_SUCCESS);
  dispatch('fetchDesigns');
};
export const requestDesignActionError = ({ commit }, error) => {
  createFlash(__('There was an error'));
  commit(types.REQUEST_DESIGN_ACTION_ERROR, error);
};

export const designAction = ({ state, dispatch }, { projectId, action }) => {
  dispatch('requestDesignAction');

  axios
    .put(`${state.endpoint}/${projectId}/${action}`, {})
    .then(() => dispatch('requestDesignActionSuccess'))
    .catch(error => {
      dispatch('requestDesignActionError', error);
      createFlash(__('There was an error'));
    });
};

// Filtering/Pagination
export const setFilter = ({ commit, dispatch }, filterIndex) => {
  commit(types.SET_FILTER, filterIndex);
  dispatch('fetchDesigns');
};
export const setSearch = ({ commit, dispatch }, search) => {
  commit(types.SET_SEARCH, search);
  dispatch('fetchDesigns');
};
export const setPage = ({ commit, dispatch }, page) => {
  commit(types.SET_PAGE, page);
  dispatch('fetchDesigns');
};
