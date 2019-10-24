import * as types from './mutation_types';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import { __ } from '~/locale';

export const setEndpoint = ({ commit }, endpoint) => commit(types.SET_ENDPOINT, endpoint);

export const requestDesigns = ({ commit }) => commit(types.REQUEST_DESIGNS);
export const receiveDesignsSuccess = ({ commit }, data) => commit(types.RECEIVE_DESIGNS_SUCCESS, data);
export const receiveDesignsError = ({ commit }, error) => commit(types.RECEIVE_DESIGNS_ERROR, error);

export const fetchDesigns = ({ state, dispatch }) => {
  dispatch('requestDesigns');

  axios.get(state.endpoint)
    .then(({ data }) => dispatch('receiveDesignsSuccess', data))
    .catch((error) => {
      dispatch('receiveDesignsError', error)
      createFlash(__('There was an error'))
    });
}