import * as types from './mutation_types';
import createFlash from '~/flash';
import { __ } from '~/locale';

// import mockData from './mock_data';
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

  /*
  console.log(`Mocking call to ${state.endpoint}`);

  new Promise(resolve => setTimeout(resolve, 3000))
    .then(() => {
      dispatch('receiveDesignsSuccess', mockData);
    })
    .catch(error => {
      dispatch('receiveDesignsError', error);
    });
  */

  axios.get(state.endpoint)
    .then(({ data }) => dispatch('receiveDesignsSuccess', data))
    .catch((error) => {
      dispatch('receiveDesignsError', error)
      createFlash(__('There was an error'))
    });
};
