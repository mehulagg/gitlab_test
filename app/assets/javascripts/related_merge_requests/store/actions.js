import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import { normalizeHeaders } from '~/lib/utils/common_utils';
import * as types from './mutation_types';

const REQUEST_PAGE_COUNT = 100;

export default {
  setInitialState: ({ commit }, props) => {
    commit(types.SET_INITIAL_STATE, props);
  },

  requestData: ({ commit }) => commit(types.REQUEST_DATA),

  receiveDataSuccess: ({ commit }, data) => commit(types.RECEIVE_DATA_SUCCESS, data),

  receiveDataError: ({ commit }) => commit(types.RECEIVE_DATA_ERROR),

  fetchMergeRequests: ({ state, dispatch }) => {
    dispatch('requestData');

    return axios
      .get(`${state.apiEndpoint}?per_page=${REQUEST_PAGE_COUNT}`)
      .then(res => {
        const { headers, data } = res;
        const total = Number(normalizeHeaders(headers)['X-TOTAL']) || 0;

        dispatch('receiveDataSuccess', { data, total });
      })
      .catch(() => {
        dispatch('receiveDataError');
        createFlash(s__('Something went wrong while fetching related merge requests.'));
      });
  },
};
